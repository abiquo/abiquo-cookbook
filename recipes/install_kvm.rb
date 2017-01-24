# Cookbook Name:: abiquo
# Recipe:: install_kvm
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

# CentOS 7 issue: https://bugs.centos.org/view.php?id=12632&nbn=2
if node['virtualization']['role'] == 'guest' && node['platform_version'].to_i >= 7
  yum_repository 'kvm-common' do
    description 'Backports for the seabios package'
    baseurl 'http://buildlogs.centos.org/centos/7/virt/x86_64/kvm-common'
    includepkgs 'seabios,seabios-bin,seavgabios-bin'
    gpgcheck false
    action :create
  end

  package 'yum-plugin-versionlock' do
    action :install
  end

  yum_package 'seabios' do
    version '1.7.5-11.el7'
    action [:lock, :install]
  end
end

package 'qemu-kvm' do
  action :install
end

%w(aim sosreport-plugins).each do |pkg|
  package "abiquo-#{pkg}" do
    action :install
  end
end

link '/usr/bin/qemu-system-x86_64' do
  to node['platform_version'].to_i > 6 ? '/usr/libexec/qemu-kvm' : '/usr/bin/qemu-kvm'
  not_if { ::File.exist?('/usr/bin/qemu-system-x86_64') }
end

service 'rpcbind' do
  action [:enable, :start]
end

include_recipe 'abiquo::kvm_neutron' if node['abiquo']['aim']['include_neutron']
