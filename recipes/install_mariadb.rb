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

# Enable replication if specified
node.set['mariadb']['replication']['server_id'] = '1' if node['abiquo']['db']['enable-master']

include_recipe 'mariadb'

# MariaDB cookbook does not restart the service after changing the config
# files, so we subscribe to the replication config file and restart if
# changed.
service 'mysql' do
  action :nothing
  subscribes :restart, 'mariadb_configuration[replication]', :immediately
  not_if { node['abiquo']['db']['enable-master'].nil? }
end

mysql2_chef_gem 'default' do
  provider Chef::Provider::Mysql2ChefGem::Mariadb
  action :install
end

conn_info = {
  host: '127.0.0.1',
  username: 'root',
  password: node['mariadb']['server_root_password']
}

# Need to grant for localhost to run the scripts
kinton_grants_from = if node['abiquo']['db']['from'] != 'localhost'
                       ['localhost', node['abiquo']['db']['from']]
                     else
                       ['localhost']
                     end
kinton_grants_from.each do |from_host|
  mysql_database_user "kinton-#{node['abiquo']['db']['user']}-#{from_host}" do
    connection    conn_info
    database_name 'kinton'
    password      node['abiquo']['db']['password']
    host          from_host
    privileges    [:all]
    action        :grant
  end
end

watchtower_grants_from = if node['abiquo']['monitoring']['db']['from'] != 'localhost'
                           ['localhost', node['abiquo']['monitoring']['db']['from']]
                         else
                           ['localhost']
                         end
watchtower_grants_from.each do |from_host|
  mysql_database_user "watchtower-#{node['abiquo']['monitoring']['db']['user']}-#{from_host}" do
    connection    conn_info
    database_name 'watchtower'
    password      node['abiquo']['monitoring']['db']['password']
    host          from_host
    privileges    [:all]
    action        :grant
  end
end
