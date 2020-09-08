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

# jdk11 keytool fix
execute 'create-jre-fake' do
  command "sudo mkdir mkdir -p /usr/java/default/jre/lib/"
end

execute 'symlink-jre-fake' do
  command "ln -s /usr/java/default/bin/ /usr/java/default/jre/"
end

execute 'symlink-cacerts' do
  command "ln -s /usr/java/default/lib/security/ /usr/java/default/jre/lib/"
end

directory '/etc/pki/abiquo' do
  recursive true
  action :create
end

ssl_certificate node['abiquo']['certificate']['common_name'] do
  namespace node['abiquo']['certificate']
  cert_path node['abiquo']['certificate']['file']
  key_path node['abiquo']['certificate']['key_file']
  not_if { ::File.exist? node['abiquo']['certificate']['file'] }
  only_if { node['abiquo']['certificate']['source'] == 'self-signed' }
  notifies :restart, 'service[apache2]' if node.recipe?('abiquo::install_frontend')
  notifies :import, "java_management_truststore_certificate[#{node['abiquo']['certificate']['common_name']}]", :immediately
  notifies :run, 'execute[convert-key-pkcs8]', :immediately if node['abiquo']['profile'] == 'monitoring'
end

# Collect additional certs
node['abiquo']['certificate']['additional_certs'].each do |cert_alias, cert|
  abiquo_download_cert cert_alias do
    host cert
    notifies :restart, 'service[abiquo-tomcat]' if node.recipe?('abiquo::service')
    action :download
  end
end

java_management_truststore_certificate node['abiquo']['certificate']['common_name'] do
  file node['abiquo']['certificate']['file']
  action :nothing
  notifies :restart, 'service[abiquo-tomcat]' if node['abiquo']['profile'] == 'server' || node['abiquo']['profile'] == 'monolithic'
  only_if { node['abiquo']['profile'] == 'monolithic' || node['abiquo']['profile'] == 'server' }
end

execute 'convert-key-pkcs8' do
  command "openssl pkcs8 -v1 PBE-SHA1-3DES -topk8 -in #{node['abiquo']['certificate']['key_file']} -out #{node['abiquo']['certificate']['key_file']}.pkcs8 -passout pass:"
  action :nothing
end
