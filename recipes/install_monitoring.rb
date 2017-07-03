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

include_recipe 'mariadb::client'

package 'jdk' do
  action :install
end

java_alternatives 'set default jdk8' do
  java_location node['java']['java_home']
  bin_cmds %w(java javac)
  action :set
end

node.set['cassandra']['config']['cluster_name'] = node['abiquo']['monitoring']['cassandra']['cluster_name']
node.set['cassandra']['install_java'] = false # The Abiquo jdk package is installed instead
include_recipe 'cassandra-dse'

service 'kairosdb' do
  action :nothing
end

package 'kairosdb' do
  action :install
  # We want the service to be stopped immediately after the rpm package starts it, if we are going
  # to replace its config file by a systemd unit. Otherwise we won't be able to properly manage it.
  notifies :stop, 'service[kairosdb]', :immediately if node['platform_version'].to_i == 7
end

# Configure a systemd script if we are in CentOS 7
file '/etc/init.d/kairosdb' do
  action :delete
  only_if { node['platform_version'].to_i == 7 }
end

systemd_unit 'kairosdb.service' do
  content <<-EOU.gsub(/^\s+/, '')
	[Unit]
	Description=KairosDB is a fast distributed scalable time series database written on top of Cassandra.
	Requires=cassandra.service
	After=cassandra.service

	[Service]
	Type=forking
	User=root
	PIDFile=/var/run/kairosdb.pid
	ExecStart=/opt/kairosdb/bin/kairosdb.sh start
	ExecStop=/opt/kairosdb/bin/kairosdb.sh stop

	[Install]
	WantedBy=multi-user.target
  EOU
  action [:create, :enable]
  notifies :restart, 'service[kairosdb]'
  only_if { node['platform_version'].to_i == 7 }
end

include_recipe 'abiquo::install_ext_services' if node['abiquo']['install_ext_services']

%w(delorean emmett).each do |pkg|
  package "abiquo-#{pkg}" do
    action :install
  end
end

if node['abiquo']['monitoring']['db']['install']

  mysql2_chef_gem 'default' do
    provider Chef::Provider::Mysql2ChefGem::Mariadb
    action :install
  end

  mysqlcmd = mysql_cmd(node['abiquo']['monitoring']['db'])

  conn_info = {
    host: node['abiquo']['monitoring']['db']['host'],
    username: node['abiquo']['monitoring']['db']['user'],
    password: node['abiquo']['monitoring']['db']['password'],
    port: node['abiquo']['monitoring']['db']['port']
  }

  # Create DB
  mysql_database 'watchtower' do
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
