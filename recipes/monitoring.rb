# Cookbook Name:: abiquo
# Recipe:: monitoring
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

kairosdb_package = "kairosdb-#{node['abiquo']['kairosdb']['version']}-#{node['abiquo']['kairosdb']['release']}.rpm"
kairosdb_url = "https://github.com/kairosdb/kairosdb/releases/download/v#{node['abiquo']['kairosdb']['version']}/#{kairosdb_package}"

remote_file "#{Chef::Config[:file_cache_path]}/#{kairosdb_package}" do
    source kairosdb_url
end

package "kairosdb" do
    source "#{Chef::Config[:file_cache_path]}/#{kairosdb_package}"
end

template '/opt/kairosdb/conf/kairosdb.properties' do
    source 'kairosdb.properties.erb'
    owner 'root'
    group 'root'
    action :create
end

package "jdk" do
    action :install
end

java_alternatives "set default jdk8" do
    java_location node['java']['java_home']
    bin_cmds ['java', 'javac']
    action :set
end

node.set['cassandra']['config']['cluster_name'] = node['abiquo']['cassandra']['cluster_name']
node.set['cassandra']['install_java'] = false   # The Abiquo jdk package is installed instead
include_recipe 'cassandra-dse'

include_recipe "iptables"
iptables_rule "firewall-policy-drop"
iptables_rule "firewall-abiquo"

# Cassandra takes some time to start. We have to wait a bit otherwise KairosDB
# will fail to start.
service 'kairosdb' do
    action :nothing
end

abiquo_wait_for_port "cassandra" do
    port node['cassandra']['config']['rpc_port'].to_i
    action :wait
    notifies :restart, "service[kairosdb]"
end
