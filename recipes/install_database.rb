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

execute "create-database" do
    command "#{mysqlcmd} -e 'CREATE DATABASE kinton'"
    not_if "#{mysqlcmd} kinton -e 'SELECT 1'"
    notifies :run, "execute[install-database]", :immediately
end

execute "install-database" do
    command "#{mysqlcmd} kinton </usr/share/doc/abiquo-server/database/kinton-schema.sql"
    action :nothing
    notifies :run, "ruby_block[extract-m-user-password]", :immediately
    notifies :run, "execute[install-license]", :immediately
end

execute "install-license" do
    command "#{mysqlcmd} kinton -e \"INSERT INTO license (data) VALUES ('#{node['abiquo']['license']}');\""
    action :nothing
    not_if { node['abiquo']['license'].nil? || node['abiquo']['license'].empty? }
end

ruby_block "extract-m-user-password" do
    block do
        Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)      
        mysql_command = "#{mysqlcmd} kinton -B --skip-column-names -e \"select COMMENTS from DATABASECHANGELOG where ID = 'default_user_for_m'\""
        mysql_command_out = shell_out!(mysql_command)
        node.set['abiquo']['properties']['abiquo.m.credential'] = mysql_command_out.stdout.gsub("\n", "")
    end
    action :run
    not_if { node['abiquo']['properties'].has_key? 'abiquo.m.credential' }
    not_if { node['abiquo']['properties'].has_key? 'abiquo.m.accessToken' }
end
