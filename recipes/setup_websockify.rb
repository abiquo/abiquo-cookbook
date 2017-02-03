# Cookbook Name:: abiquo
# Recipe:: setup_websockify
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

if node['platform_version'].to_i == 7
  template '/etc/sysconfig/websockify' do
    source "#{node['platform_family']}/#{node['platform_version'].to_i}/conf-websockify.erb"
    owner 'root'
    group 'root'
    action :create
    notifies :restart, 'service[websockify]'
  end
else
  template '/etc/init.d/websockify' do
    source 'websockify.erb'
    owner 'root'
    group 'root'
    variables(websockify_port: node['abiquo']['websockify']['port'],
              websockify_address: node['abiquo']['websockify']['address'])
    action :create
    notifies :restart, 'service[websockify]'
  end
end

template '/opt/websockify/abiquo.cfg' do
  source 'ws_abiquo.cfg.erb'
  owner 'root'
  group 'root'
  variables(wsvars: node['abiquo']['websockify']['conf'])
  action :create
  notifies :restart, 'service[websockify]'
end

haproxy_instance 'haproxy' do
  proxies [resources(haproxy_frontend: 'public'), resources(haproxy_backend: 'ws')]
  tuning ['maxconn 1024']
end
