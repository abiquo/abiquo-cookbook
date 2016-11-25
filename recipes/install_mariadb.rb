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

mysql_database_user node['abiquo']['db']['user'] do
  connection conn_info
  password   node['abiquo']['db']['password']
  host       node['abiquo']['db']['from']
  privileges [:all]
  action     :grant
end

mysql_database_user node['abiquo']['monitoring']['db']['user'] do
  connection conn_info
  password   node['abiquo']['monitoring']['db']['password']
  host       node['abiquo']['monitoring']['db']['from']
  privileges [:all]
  action     :grant
end
