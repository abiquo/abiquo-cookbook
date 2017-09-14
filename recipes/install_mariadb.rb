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
if node['abiquo']['db']['enable-master']
  node.set['mariadb']['replication']['server_id'] = '1'
  node.set['mariadb']['replication']['options']['binlog_format'] = 'ROW'
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

# mysql2_chef_gem 'default' do
#   provider Chef::Provider::Mysql2ChefGem::Mariadb
#   action :install
# end

# Due to https://github.com/brianmario/mysql2/issues/878
# mysql2 gem will not build with MariaDB 10.2 so we need
# to install from git including the fix
# TODO: Revert back to gem once the fix is merged and released.
%w(git make gcc).each do |pkg|
  package pkg
end

git '/usr/local/src/mysql2-gem' do
  repository 'https://github.com/actsasflinn/mysql2'
  revision 'f60600dae11d3cf629c1b895a4051e5572c13978'
end

execute "#{RbConfig::CONFIG['bindir']}/gem build mysql2.gemspec" do
  cwd '/usr/local/src/mysql2-gem'
  creates '/usr/local/src/mysql2-gem/mysql2-0.4.9.gem'
end

chef_gem 'mysql2' do
  source '/usr/local/src/mysql2-gem/mysql2-0.4.9.gem'
  compile_time false
end

conn_info = {
  host: '127.0.0.1',
  username: 'root',
  password: node['mariadb']['server_root_password'],
}

# Need to grant for localhost to run the scripts
schemas = %w(kinton kinton_accounting)
kinton_grants_from = if node['abiquo']['db']['from'] != 'localhost'
                       ['localhost', node['abiquo']['db']['from']]
                     else
                       ['localhost']
                     end
schemas.each do |schema|
  kinton_grants_from.each do |from_host|
    mysql_database_user "#{schema}-#{node['abiquo']['db']['user']}-#{from_host}" do
      connection    conn_info
      database_name schema
      username      node['abiquo']['db']['user']
      password      node['abiquo']['db']['password']
      host          from_host
      privileges    [:all]
      action        :grant
    end
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
    username      node['abiquo']['monitoring']['db']['user']
    password      node['abiquo']['monitoring']['db']['password']
    host          from_host
    privileges    [:all]
    action        :grant
  end
end
