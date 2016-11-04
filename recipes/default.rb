# Cookbook Name:: abiquo
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

selinux_state 'SELinux Permissive' do
  action :permissive
end

include_recipe 'abiquo::repository'
include_recipe "abiquo::install_#{node['abiquo']['profile']}"
include_recipe "abiquo::setup_#{node['abiquo']['profile']}"

include_recipe 'iptables'
iptables_rule 'firewall-common'
iptables_rule "firewall-#{node['abiquo']['profile']}"

package 'cronie' do
  action :install
end

service 'crond' do
  action [:enable, :start]
end
