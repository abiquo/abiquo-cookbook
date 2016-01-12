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

execute "create-database" do
    command '/usr/bin/mysql -e "CREATE DATABASE IF NOT EXISTS kinton"'
end

execute "install-database" do
    command "/usr/bin/mysql kinton </usr/share/doc/abiquo-server/database/kinton-schema.sql"
end

execute "install-license" do
    command "/usr/bin/mysql kinton -e \"INSERT INTO license (data) VALUES ('#{node['abiquo']['license']}');\""
    not_if { node['abiquo']['license'].nil? || node['abiquo']['license'].empty? }
end

ruby_block "extract_m_user_password" do
  block do
    Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)      
    mysql_command = 'mysql kinton -B --skip-column-names -e "select COMMENTS from DATABASECHANGELOG where ID = \'default_user_for_m\'"'
    mysql_command_out = shell_out!(mysql_command)
    node.default['abiquo']['properties']['abiquo.m.credential'] = mysql_command_out.stdout.gsub("\n", "")
  end
  action :run
end