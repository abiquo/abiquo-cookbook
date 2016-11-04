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
  not_if { ::File.file? "node['abiquo']['certificate']['file']" }
  only_if { node['abiquo']['certificate']['source'] == 'self-signed' }
  notifies :restart, 'service[apache2]' if node.recipe?('abiquo::install_ui')
  notifies :import, "java_management_truststore_certificate[#{node['abiquo']['certificate']['common_name']}]", :immediately
  notifies :create, "template[#{node['abiquo']['certificate']['file']}.haproxy.crt]", :immediately
end

# Collect additional certs
node['abiquo']['certificate']['additional_certs'].each do |cert_alias, cert|
  abiquo_download_cert cert_alias do
    host cert
    notifies :restart, 'service[abiquo-tomcat]' if node.recipe?('abiquo::service')
    action :download
  end
end

template "#{node['abiquo']['certificate']['file']}.haproxy.crt" do
  source 'haproxy-cert.erb'
  owner 'root'
  group 'root'
  variables(cert: node['abiquo']['certificate']['file'],
            key: node['abiquo']['certificate']['key_file'])
  action :nothing
end

java_management_truststore_certificate node['abiquo']['certificate']['common_name'] do
  file node['abiquo']['certificate']['file']
  action :nothing
  notifies :restart, 'service[abiquo-tomcat]' if node['abiquo']['profile'] == 'server' || node['abiquo']['profile'] == 'monolithic'
  only_if { node['abiquo']['profile'] == 'monolithic' || node['abiquo']['profile'] == 'server' }
end
