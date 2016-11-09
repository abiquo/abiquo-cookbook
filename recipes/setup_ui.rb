# Cookbook Name:: abiquo
# Recipe:: setup_ui
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
json_settings = Chef::JSONCompat.to_json_pretty(node['abiquo']['ui_config'])

file '/var/www/html/ui/config/client-config-custom.json' do
  content json_settings
  owner 'root'
  group 'root'
  action :create
  notifies :restart, 'service[apache2]'
end

ws_proxies = []
ws_proxies << resources(haproxy_frontend: 'public')
if node['abiquo']['haproxy']['use_default_path']
  ws_proxies << resources(haproxy_backend: 'ws')
else
  node['abiquo']['haproxy']['ws_paths'].each do |path, _dest|
    ws_proxies << resources(haproxy_backend: path.downcase.tr('/', '_'))
  end
end
node.set['abiquo']['haproxy']['ws_proxies'] = ws_proxies

haproxy_instance 'haproxy' do
  proxies node['abiquo']['haproxy']['ws_proxies']
  config ['user haproxy', 'group haproxy', 'log /dev/log local0']
  tuning ['maxconn 1024']
end
