# Cookbook Name:: abiquo
# Recipe:: install_database
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

mysqlcmd = mysql_cmd(node['abiquo']['db'])

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
  host: node['abiquo']['db']['host'],
  username: node['abiquo']['db']['user'],
  password: node['abiquo']['db']['password'],
  port: node['abiquo']['db']['port'],
}

# Create DB
mysql_database 'kinton' do
  connection conn_info
  action :create
  notifies :run, 'execute[install-database]', :immediately
end

execute 'install-database' do
  command "#{mysqlcmd} kinton </usr/share/doc/abiquo-model/database/kinton-schema.sql"
  action :nothing
  notifies :run, 'ruby_block[extract-m-user-password]', :immediately
  notifies :query, 'mysql_database[install-license]', :immediately
end

# Install license if present
mysql_database 'install-license' do
  connection conn_info
  database_name 'kinton'
  sql "INSERT INTO license (data) VALUES ('#{node['abiquo']['license']}')"
  action :nothing
  not_if { node['abiquo']['license'].nil? || node['abiquo']['license'].empty? }
end

# Extract M user password from databases
# Randomly generated after liquibase run
ruby_block 'extract-m-user-password' do
  block do
    client = Mysql2::Client.new(conn_info.merge(database: 'kinton'))
    query = 'select COMMENTS from DATABASECHANGELOG where ID = "default_user_for_m"'
    result = client.query(query).first['COMMENTS']
    node.normal['abiquo']['properties']['abiquo.m.credential'] = result
  end
  action :nothing
  not_if { node['abiquo']['properties'].key? 'abiquo.m.credential' }
  not_if { node['abiquo']['properties'].key? 'abiquo.m.accessToken' }
end
