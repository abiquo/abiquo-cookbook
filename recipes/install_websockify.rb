# Cookbook Name:: abiquo
# Recipe:: install_websockify
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

%w(libxslt libxml2).each do |pkg|
  package pkg do
    action :install
  end
end

package 'abiquo-websockify' do
  action :install
end

service 'websockify' do
  action [:enable, :start]
end

include_recipe 'abiquo::certificate'

include_recipe 'haproxy-ng::install'
include_recipe 'haproxy-ng::service'

haproxy_backend 'ws' do
  balance 'source'
  servers [
    { 'name' => 'websockify1',
      'address' => node['abiquo']['websockify']['address'],
      'port' => node['abiquo']['websockify']['port'],
      'config' => 'weight 1 maxconn 1024 check' }
  ]
  config [
    'timeout queue 3600s',
    'timeout server 3600s',
    'timeout connect 3600s'
  ]
end

haproxy_frontend 'public' do
  bind "#{node['abiquo']['haproxy']['address']}:#{node['abiquo']['haproxy']['port']} ssl crt #{node['abiquo']['haproxy']['certificate']}"
  default_backend 'ws'
  config ['timeout client 3600s']
end
