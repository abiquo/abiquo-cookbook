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

package 'qemu-kvm' do
    action :install
end

%w(cloud-node sosreport-plugins).each do |pkg|
    package "abiquo-#{pkg}" do
        action :install
    end
end

link '/usr/bin/qemu-system-x86_64' do
    to '/usr/bin/qemu-kvm'
    not_if { ::File.exist?('/usr/bin/qemu-system-x86_64') }
end

service 'rpcbind' do
    action [:enable, :start]
end
