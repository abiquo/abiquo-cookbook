# Cookbook Name:: abiquo_test
# Recipe:: default
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

abiquo_license 'test license' do
  code 'aDWNPdzzj9Dd1uUM+kE+dOj/FvO00Z71v6Ux0RCMGd/BgaGeq/Drwgc6xvrC9m9h+gawA+FlyrUoDtoVHqPMXRDsIru5E+GvdY95hZ5zhf45qsg1FnfbuSGN7uXNum/d5Eozgu6ukGSG7GQ9hmp4Ednods1YZr6AZ4SbYmKsxVQeOmg36T04mpF23rtjD4hr3vB3DZz2EZ1nEBHVxETp8PQFmb152RMcG+A5MTQPZFy0TF/xFSsRVFT0TJ/eByszq/R/2ChHoQWOe72+qH52G5VNpmi9Ud/Yt/SHZTxawdfXOpf9LxSdIubpSe5OD0Q58826SVOnv0xA9mS6gbKLWiIBOA+3If0AVscqBU+pWDhYxEmWz+Z/Vc/H1uHPuqTWsJPmvYOxElRIqbVr2dn/+kbSjqwK33tBF1VN3pzfEQahREuTGR1LA3CPqGk9X5fHMGksYMF4P45mij+juNoF7i7kEh5/ULesnqUZEy8Nbq6n/VgsrJ3cXhsluHfO78gvRemEdggmCGYBTfritP/txkjj+YS0T0ToaYLQAXzYmcnC6fKKA8/4gE9CSY64IKrG3zBFC8VdJBCF6FnDhiLwF0ezBUpOwvN+FEY4gDXNMQbPJMU7L6m15AijqVPG8/kHZJcEe+0aARctqmb9Qwcr9+cVEWkDrXcuPC/6T5rtX3M='
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :nothing
  subscribes :create, 'abiquo_wait_for_webapp[api]'
end

abiquo_datacenter 'test dc' do
  location "Somewhere over the rainbows"
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :nothing
  subscribes :create, 'abiquo_wait_for_webapp[api]'
  notifies :create, 'abiquo_rack[test rack]'
end

abiquo_public_cloud_region 'aws eu-west-1' do
  region 'eu-west-1'
  cloud_provider 'AMAZON'
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :nothing
  subscribes :create, 'abiquo_wait_for_webapp[api]'
end

# Create rack
abiquo_rack 'test rack' do
  datacenter 'test dc'
  vlan_min 100
  vlan_max 150
  vlan_avoided '111'
  vlan_reserved 2
  nrsq 1
  ha_enabled true
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :nothing
end

# Create Remote Services
abiquo_remote_service "http://#{node['ipaddress']}:8009/vsm" do
  type "VIRTUAL_SYSTEM_MONITOR"
  datacenter [ 'test dc', 'aws eu-west-1']
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :nothing
  subscribes :create, 'abiquo_wait_for_webapp[api]'
end

abiquo_remote_service "http://#{node['ipaddress']}:8009/nodecollector" do
  type "NODE_COLLECTOR"
  datacenter [ 'test dc', 'aws eu-west-1']
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :nothing
  subscribes :create, 'abiquo_wait_for_webapp[api]'
end

abiquo_remote_service "http://#{node['ipaddress']}:8009/virtualfactory" do
  type "VIRTUAL_FACTORY"
  datacenter [ 'test dc', 'aws eu-west-1']
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :nothing
  subscribes :create, 'abiquo_wait_for_webapp[api]'
end

abiquo_remote_service "http://#{node['ipaddress']}:8009/ssm" do
  type "STORAGE_SYSTEM_MONITOR"
  datacenter 'test dc'
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :nothing
  subscribes :create, 'abiquo_wait_for_webapp[api]'
end

abiquo_remote_service "https://#{node['hostname']}:443/am" do
  type "APPLIANCE_MANAGER"
  uuid node['abiquo']['properties']['abiquo.datacenter.id']
  datacenter 'test dc'
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :nothing
  subscribes :create, 'abiquo_wait_for_webapp[api]'
  ignore_failure true
end

abiquo_remote_service "http://#{node['ipaddress']}:8009/bpm-async" do
  type "BPM_SERVICE"
  uuid node['abiquo']['properties']['abiquo.datacenter.id']
  datacenter 'test dc'
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :nothing
  subscribes :create, 'abiquo_wait_for_webapp[api]'
end

abiquo_remote_service "http://#{node['ipaddress']}:8009/cpp" do
  type "CLOUD_PROVIDER_PROXY"
  datacenter 'aws eu-west-1'
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :nothing
  subscribes :create, 'abiquo_wait_for_webapp[api]'
end

# File required in order to use the vm_repository
file '/opt/vm_repository/.abiquo_repository' do 
  content ''
  owner 'root'
  group 'root'
  action :nothing
  subscribes :create, 'abiquo_rack[test rack]'
end

abiquo_machine "#{node['ipaddress']}" do 
  type "KVM"
  port node['abiquo']['aim']['port']
  datastore_root "/"
  datastore_dir "/var/lib/virt"
  service_nic "eth0"
  datacenter 'test dc'
  rack 'test rack'
  abiquo_api_url "https://localhost/api"
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :nothing
  subscribes :create, 'file[/opt/vm_repository/.abiquo_repository]'
end

ruby_block "dump node attributes to file" do
  block do
    require 'json'
    ::File.open('/tmp/node_attributes.json', 'w') do |f|
      f.write(node.to_json)
    end
  end
  action :run
end