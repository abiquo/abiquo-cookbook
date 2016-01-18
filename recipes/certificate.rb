# Cookbook Name:: abiquo
# Recipe:: certificate
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

directory '/etc/pki/abiquo' do
  recursive true
  action :create
end

ssl_certificate node['abiquo']['certificate']['common_name'] do
  namespace node['abiquo']['certificate']
  cert_path node['abiquo']['certificate']['file']
  key_path  node['abiquo']['certificate']['key_file']
  not_if { ::File.file? "/etc/pki/abiquo/#{node['abiquo']['certificate']['common_name']}.crt" }
  notifies :restart, 'service[apache2]'
end

java_management_truststore_certificate node['abiquo']['certificate']['common_name'] do
  file node['abiquo']['certificate']['file']
  action :nothing
  subscribes :import, "ssl_certificate[#{node['abiquo']['certificate']['common_name']}]", :immediately
  notifies :start, "service[abiquo-tomcat]"
end
