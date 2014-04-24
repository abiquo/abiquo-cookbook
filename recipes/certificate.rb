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

include_recipe "selfsigned_certificate"

java_management_truststore_certificate "abiquo" do
    file "#{node['selfsigned_certificate']['destination']}/server.crt"
    keystore node['abiquo']['ssl']['keystore']
    keytool node['abiquo']['ssl']['keytool']
    storepass node['abiquo']['ssl']['storepass']
end

file node['abiquo']['ssl']['certificatefile'] do
    owner 'root'
    group 'root'
    mode 0644
    content lazy { ::File.open("#{node['selfsigned_certificate']['destination']}/server.crt").read }
    action :create
end

file node['abiquo']['ssl']['keyfile'] do
    owner 'root'
    group 'root'
    mode 0644
    content lazy { ::File.open("#{node['selfsigned_certificate']['destination']}/server.key").read }
    action :create
end
