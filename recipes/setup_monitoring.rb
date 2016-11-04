# Cookbook Name:: abiquo
# Recipe:: setup_monitoring
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

service 'kairosdb' do
  action :nothing
end

template '/opt/kairosdb/conf/kairosdb.properties' do
  source 'kairosdb.properties.erb'
  owner 'root'
  group 'root'
  action :create
  notifies :restart, 'service[kairosdb]'
end

%w(delorean emmett).each do |wts|
  service "abiquo-#{wts}" do
    action :enable
    # They still don't handle well reconnections, so restart them when needed
    subscribes :restart, 'service[kairosdb]'
  end

  file "/etc/abiquo/watchtower/#{wts}-base.conf" do
    owner 'root'
    group 'root'
    content lazy { ::IO.read("/etc/abiquo/watchtower/#{wts}.conf") }
    action :create
    not_if { ::File.exist? "/etc/abiquo/watchtower/#{wts}-base.conf" }
  end

  template "/etc/abiquo/watchtower/#{wts}.conf" do
    source 'watchtower-service.conf.erb'
    owner 'root'
    group 'root'
    variables(watchtower_service: wts)
    action :create
    notifies :restart, "service[abiquo-#{wts}]"
  end
end

# KairosDB might fail to start as C* takes some time until it is started
# Restart Kairos once everything is up and running
abiquo_wait_for_port 'cassandra' do
  port node['cassandra']['config']['rpc_port'].to_i
  action :nothing
  subscribes :wait, 'service[cassandra]'
  notifies :restart, 'service[kairosdb]'
end
