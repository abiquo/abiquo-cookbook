# Cookbook Name:: abiquo
# Recipe:: install_mariadb
#
# Copyright 2014, Abiquo
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Chef::Recipe.send(:include, Abiquo::Commands)

# Enable replication if specified
if node['abiquo']['db']['enable-master']
  node.default['mariadb']['replication']['server_id'] = '1'
  node.default['mariadb']['replication']['options']['binlog_format'] = 'ROW'
end

include_recipe 'mariadb'

# MariaDB cookbook does not restart the service after changing the config
# files, so we subscribe to the replication config file and restart if
# changed.
service 'mysql' do
  action :nothing
  subscribes :restart, 'mariadb_configuration[30-replication]', :immediately
  not_if { node['abiquo']['db']['enable-master'].nil? }
end

mysql2_chef_gem_mariadb 'default' do
  action :install
end

conn_info = {
  host: '127.0.0.1',
  user: 'root',
  port: 3306,
  password: node['mariadb']['server_root_password'],
}

# Need to grant for localhost to run the scripts
schemas = %w(kinton kinton_accounting)
kinton_grants_from = if node['abiquo']['db']['from'] != 'localhost'
                       ['localhost', node['abiquo']['db']['from']]
                     else
                       ['localhost']
                     end
kinton_grants_from.each do |from_host|
  schemas.each do |schema|
    abiquo_mysql_database_user "#{schema}-#{node['abiquo']['db']['user']}-#{from_host}" do
      connection    conn_info
      database_name schema
      username      node['abiquo']['db']['user']
      password      node['abiquo']['db']['password']
      host          from_host
      privileges    [:all]
      action        :grant
    end
  end

  # If binary logging is enabled
  # SUPER priv is required to run the accounting
  # schema upgrade
  abiquo_mysql_database_user "#{node['abiquo']['db']['user']}-#{from_host}-super" do
    connection    conn_info
    username      node['abiquo']['db']['user']
    password      node['abiquo']['db']['password']
    host          from_host
    privileges    [:SUPER]
    action        :grant
    only_if       { node['abiquo']['db']['enable-master'] }
  end
end

watchtower_grants_from = if node['abiquo']['monitoring']['db']['from'] != 'localhost'
                           ['localhost', node['abiquo']['monitoring']['db']['from']]
                         else
                           ['localhost']
                         end
watchtower_grants_from.each do |from_host|
  abiquo_mysql_database_user "watchtower-#{node['abiquo']['monitoring']['db']['user']}-#{from_host}" do
    connection    conn_info
    database_name 'watchtower'
    username      node['abiquo']['monitoring']['db']['user']
    password      node['abiquo']['monitoring']['db']['password']
    host          from_host
    privileges    [:all]
    action        :grant
  end
end
