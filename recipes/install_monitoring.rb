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

kairosdb_package = "kairosdb-#{node['abiquo']['monitoring']['kairosdb']['version']}-#{node['abiquo']['monitoring']['kairosdb']['release']}.rpm"
kairosdb_url = "https://github.com/kairosdb/kairosdb/releases/download/v#{node['abiquo']['monitoring']['kairosdb']['version']}/#{kairosdb_package}"

remote_file "#{Chef::Config[:file_cache_path]}/#{kairosdb_package}" do
    source kairosdb_url
end

package "kairosdb" do
    source "#{Chef::Config[:file_cache_path]}/#{kairosdb_package}"
end

package "jdk" do
    action :install
end

java_alternatives "set default jdk8" do
    java_location node['java']['java_home']
    bin_cmds ['java', 'javac']
    action :set
end

node.set['cassandra']['config']['cluster_name'] = node['abiquo']['monitoring']['cassandra']['cluster_name']
node.set['cassandra']['install_java'] = false   # The Abiquo jdk package is installed instead
include_recipe 'cassandra-dse'

include_recipe "abiquo::install_ext_services" if node['abiquo']['install_ext_services']

%w{delorean emmett}.each do |pkg|
    package "abiquo-#{pkg}" do
        action :install
    end
end

if node['abiquo']['monitoring']['db']['install']
    mysqlcmd = mysql_cmd node['abiquo']['monitoring']['db']

    execute "install-watchtower-database" do
        command "#{mysqlcmd} < /usr/share/doc/abiquo-watchtower/database/watchtower_schema.sql"
        not_if "#{mysqlcmd} watchtower -e 'SELECT 1'"
    end
end
