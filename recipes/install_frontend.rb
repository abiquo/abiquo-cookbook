# Cookbook Name:: abiquo
# Recipe:: install_frontend
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
    '/m' => { 'url' => "http://localhost:#{node['abiquo']['tomcat']['http-port']}/m" },
  }.merge(node['abiquo']['ui_proxies'])
when 'server'
  node.set['abiquo']['ui_proxies'] = {
    '/api' => { 'url' => "ajp://localhost:#{node['abiquo']['tomcat']['ajp-port']}/api" },
    '/legal' => { 'url' => "ajp://localhost:#{node['abiquo']['tomcat']['ajp-port']}/legal" },
    '/m' => { 'url' => "http://localhost:#{node['abiquo']['tomcat']['http-port']}/m" },
  }.merge(node['abiquo']['ui_proxies'])
end

# Apache 2.4 uses Require directives
# needed on every location
require_hash = node['platform_version'].to_i == 6 ? {} : { 'Require' => 'all granted' }

node['abiquo']['ui_proxies'].each_key do |k|
  node.set['abiquo']['ui_proxies'][k]['options'] ||= {}
  node.set['abiquo']['ui_proxies'][k]['options'] = require_hash.merge(node['abiquo']['ui_proxies'][k]['options'])
end

web_app 'abiquo' do
  template "#{node['platform_family']}/#{node['platform_version'].to_i}/abiquo.conf.erb"
  server_name node['abiquo']['certificate']['common_name']
  cert_file node['abiquo']['certificate']['file']
  key_file node['abiquo']['certificate']['key_file']
  ca_file node['abiquo']['certificate']['ca_file']
end
