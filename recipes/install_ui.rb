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
    '/api' => "ajp://localhost:#{node['abiquo']['tomcat']['ajp-port']}/api",
    '/legal' => "ajp://localhost:#{node['abiquo']['tomcat']['ajp-port']}/legal",
    '/am' => "ajp://localhost:#{node['abiquo']['tomcat']['ajp-port']}/am",
    '/m' => "http://localhost:#{node['abiquo']['tomcat']['http-port']}/m"
  }.merge(node['abiquo']['ui_proxies'])
when 'server'
  node.set['abiquo']['ui_proxies'] = {
    '/api' => "ajp://localhost:#{node['abiquo']['tomcat']['ajp-port']}/api",
    '/legal' => "ajp://localhost:#{node['abiquo']['tomcat']['ajp-port']}/legal",
    '/m' => "http://localhost:#{node['abiquo']['tomcat']['http-port']}/m"
  }.merge(node['abiquo']['ui_proxies'])
end

web_app 'abiquo' do
  template 'abiquo.conf.erb'
  server_name node['abiquo']['certificate']['common_name']
  cert_file node['abiquo']['certificate']['file']
  key_file node['abiquo']['certificate']['key_file']
  ca_file node['abiquo']['certificate']['ca_file']
end
