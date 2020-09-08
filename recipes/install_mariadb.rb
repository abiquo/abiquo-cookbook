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

# MariaDB cookbook does not restart the service after changing the config
# files, so we subscribe to the replication config file and restart if
# changed.
service 'mariadb' do
  action :nothing
  subscribes :restart, 'mariadb_configuration[30-replication]', :immediately
  not_if { node['abiquo']['db']['enable-master'].nil? }
end

mariadb_client_install 'MariaDB Client install' do
  version '10.4.10'
  setup_repo false
end

package 'MariaDB-server' do
  action :install
end

package 'MariaDB-devel' do
  action :install
end

service 'mariadb' do
  action :restart
end

# Create DB
execute 'create-database' do
  command "sudo mysql -e 'create database kinton'"
end

# Import Schema
execute 'install-database' do
  command "sudo mysql kinton </usr/share/doc/abiquo-model/database/kinton-schema.sql"
end

# Install license if present
execute 'install-license' do
  command "sudo mysql -e \"INSERT INTO kinton.license (data) VALUES ('#{node['abiquo']['license']}')\""
  not_if { node['abiquo']['license'].nil? || node['abiquo']['license'].empty? }
end

# MariaDB >10.4.3 introduced unix_sockets auth by default, we need to force root to use password in order for tomcat/JDBC to conncet
execute 'update-user-auth' do
  command "sudo mysql -e 'ALTER USER root@localhost IDENTIFIED VIA mysql_native_password'"
end

