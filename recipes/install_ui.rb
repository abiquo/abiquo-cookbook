# Cookbook Name:: abiquo
# Recipe:: install_ui
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

include_recipe 'apache2'
include_recipe 'apache2::mod_proxy_ajp'
include_recipe 'apache2::mod_proxy_http'
include_recipe 'apache2::mod_ssl'

%w(ui tutorials).each do |pkg|
  package "abiquo-#{pkg}" do
    action :install
  end
end

include_recipe 'abiquo::certificate'

case node['abiquo']['profile']
when 'monolithic'
  node.set['abiquo']['ui_proxies'] = {
    '/api' => { 'url' => "ajp://localhost:#{node['abiquo']['tomcat']['ajp-port']}/api" },
    '/legal' => { 'url' => "ajp://localhost:#{node['abiquo']['tomcat']['ajp-port']}/legal" },
    '/am' => { 'url' => "ajp://localhost:#{node['abiquo']['tomcat']['ajp-port']}/am" },
    '/m' => { 'url' => "http://localhost:#{node['abiquo']['tomcat']['http-port']}/m" }
  }.merge(node['abiquo']['ui_proxies'])
when 'server'
  node.set['abiquo']['ui_proxies'] = {
    '/api' => { 'url' => "ajp://localhost:#{node['abiquo']['tomcat']['ajp-port']}/api" },
    '/legal' => { 'url' => "ajp://localhost:#{node['abiquo']['tomcat']['ajp-port']}/legal" },
    '/m' => { 'url' => "http://localhost:#{node['abiquo']['tomcat']['http-port']}/m" }
  }.merge(node['abiquo']['ui_proxies'])
end

web_app 'abiquo' do
  template 'abiquo.conf.erb'
  server_name node['abiquo']['certificate']['common_name']
  cert_file node['abiquo']['certificate']['file']
  key_file node['abiquo']['certificate']['key_file']
  ca_file node['abiquo']['certificate']['ca_file']
end

include_recipe 'haproxy-ng::install'
include_recipe 'haproxy-ng::service'

ws_acls = []
ws_use_backends = []
node['abiquo']['haproxy']['ws_paths'].each do |path, dest|
  # Build backends
  haproxy_backend path.downcase.tr('/', '_') do
    balance 'source'
    mode 'http'
    dest.each_with_index do |d, i|
      servers [
        { 'name' => "websockify#{i}",
          'address' => d,
          'port' => node['abiquo']['websockify']['port'],
          'config' => 'weight 1 maxconn 1024 check' }
      ]
    end
    config [
      'log global',
      'timeout queue 3600s',
      'timeout server 3600s',
      'timeout connect 3600s'
    ]
  end

  # Create ACLs for the frontend
  ws_acls << { 'name' => path.downcase.tr('/', '_'), 'criterion' => "path #{path}" }
  ws_use_backends << { 'backend' => path.downcase.tr('/', '_'), 'condition' => "if #{path.downcase.tr('/', '_')}" }
end
node.set['abiquo']['haproxy']['acls'] = ws_acls
node.set['abiquo']['haproxy']['use_backends'] = ws_use_backends

haproxy_frontend 'public' do
  bind "#{node['abiquo']['haproxy']['address']}:#{node['abiquo']['haproxy']['port']} ssl crt #{node['abiquo']['haproxy']['certificate']}"
  acls node['abiquo']['haproxy']['acls']
  use_backends node['abiquo']['haproxy']['use_backends']
  mode 'http'
  config [
    'timeout client 3600s',
    'log global'
  ]
end
