# Cookbook Name:: abiquo
# Recipe:: kvm_neutron
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

package 'centos-release-openstack-kilo' do
  action :install
end

package 'openstack-neutron' do
  # There are several versions of the package in the CentOS repos, so we'd better be explicit
  version '2015.1.4-1.el7'
  action :install
end

%w(openstack-neutron-ml2 openstack-neutron-linuxbridge).each do |pkg|
  package pkg do
    action :install
  end
end

template '/etc/neutron/neutron.conf' do
  source 'neutron.conf.erb'
  owner 'root'
  group 'neutron'
  action :create
  notifies :restart, 'service[neutron-linuxbridge-agent]'
end

template '/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini' do
  source 'neutron-linuxbridge.conf.erb'
  owner 'root'
  group 'neutron'
  action :create
  notifies :restart, 'service[neutron-linuxbridge-agent]'
end

file '/etc/neutron/plugin.ini' do
  action :delete
  not_if { ::File.symlink? '/etc/neutron/plugin.ini' }
end

link '/etc/neutron/plugin.ini' do
  to '/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini'
end

service 'neutron-linuxbridge-agent' do
  action [:enable, :start]
end

# Required to let iptables filter traffic on bridged interfaces
kernel_module 'br_netfilter' do
  onboot true
  reload false
end

include_recipe 'sysctl'
sysctl_param 'net.bridge.bridge-nf-call-iptables' do
  value 1
end
