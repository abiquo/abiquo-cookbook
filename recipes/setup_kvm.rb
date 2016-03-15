# Cookbook Name:: abiquo
# Recipe:: setup_kvm
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

# The device attribute is mandatory for the mount resource, so we can't use a regular guard
unless node['abiquo']['nfs']['location'].nil? # ~FC023
    mount node['abiquo']['nfs']['mountpoint'] do
        device node['abiquo']['nfs']['location']
        fstype "nfs"
        action [:enable, :mount]
    end
end

if node['platform'].eql? 'centos' or node['platform'].eql? 'redhat'
    template "/etc/sysconfig/libvirt-guests" do
        source "libvirt-guests.erb"
        owner "root"
        group "root"
        action :create
        notifies :restart, "service[abiquo-aim]"
    end
end

template "/etc/abiquo-aim.ini" do
    source "abiquo-aim.ini.erb"
    owner "root"
    group "root"
    action :create
    notifies :restart, "service[abiquo-aim]"
end

service "abiquo-aim" do
    action [:enable, :start]
end
