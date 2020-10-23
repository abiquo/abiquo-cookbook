# Cookbook Name:: abiquo
# Recipe:: install_monitoring
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

mariadb_client_install 'MariaDB Client install' do
  action :install
end

mariadb_server_install 'MariaDB Server install' do
  action :install
end

service 'mariadb' do
  action :restart
end

package 'javajdk' do
  action :install
end

java_alternatives 'set default jdk8' do
  java_location node['java']['java_home']
  bin_cmds %w(java javac)
  action :set
end

node.default['cassandra']['config']['cluster_name'] = node['abiquo']['monitoring']['cassandra']['cluster_name']
node.default['cassandra']['install_java'] = false # The Abiquo jdk package is installed instead
include_recipe 'cassandra-dse'

package 'kairosdb' do
  action :install
end

service 'kairosdb' do
  action :enable
  notifies :install, 'package[abiquo-emmett]', :immediately
  notifies :install, 'package[abiquo-delorean]', :immediately
end

#include_recipe 'abiquo::install_ext_services' if node['abiquo']['install_ext_services']
include_recipe 'abiquo::certificate' if node['abiquo']['monitoring']['emmett']['ssl']

%w(delorean emmett).each do |pkg|
  package "abiquo-#{pkg}" do
    action :install
  end
end

if node['abiquo']['monitoring']['db']['install']

  ## Package MariaDB-devel is required to be able to build the mysql2 gem
  package 'MariaDB-devel' do
    action :install
  end

  ## Package MariaDB-shared is required to be able to build the mysql2 gem
  yum_package 'MariaDB-shared-10.4.10' do
    action :install
  end

  mysql2_chef_gem_mariadb 'default' do
    gem_version '0.5.2'
    action :install
  end

  mysqlcmd = mysql_cmd(node['abiquo']['monitoring']['db'])

  conn_info = {
    host: node['abiquo']['monitoring']['db']['host'],
    username: node['abiquo']['monitoring']['db']['user'],
    password: node['abiquo']['monitoring']['db']['password'],
    port: node['abiquo']['monitoring']['db']['port'],
  }

  # MariaDB >10.4.3 introduced unix_sockets auth by default, we need to force root to use password in order for tomcat/JDBC to conncet
  execute 'update-user-auth' do
    command "sudo mysql -e 'ALTER USER root@localhost IDENTIFIED VIA mysql_native_password'"
  end

  # Create DB
  abiquo_mysql_database 'watchtower' do
    connection conn_info
    action :create
    notifies :run, 'execute[install-watchtower-database]', :immediately
  end

  execute 'install-watchtower-database' do
    command "#{mysqlcmd} watchtower < /usr/share/doc/abiquo-watchtower/database/src/watchtower-1.0.0.sql"
    action :nothing
    notifies :run, 'execute[watchtower-liquibase-update]', :immediately
  end

  lqb_cmd = liquibase_cmd('update', node['abiquo']['monitoring']['db'], true)
  execute 'watchtower-liquibase-update' do
    command lqb_cmd
    action :nothing
  end
end
