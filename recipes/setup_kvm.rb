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

abiquo_nfs node['abiquo']['nfs']['mountpoint'] do
    share node['abiquo']['nfs']['location']
    oldshare "10.60.1.72:/opt/vm_repository"
    action :configure
    not_if { node['abiquo']['nfs']['location'].nil? }
end

template "/etc/sysconfig/libvirt-guests" do
    source "libvirt-guests.erb"
    owner "root"
    group "root"
    action :create
    notifies :restart, "service[abiquo-aim]"
end

template "/etc/abiquo-aim.ini" do
    source "abiquo-aim.ini.erb"
    owner "root"
    group "root"
    action :create
    notifies :restart, "service[abiquo-aim]"
end

service "abiquo-aim" do
    provider Chef::Provider::Service::RedhatNoStatus
    supports :restart => true
    pattern "abiquo-aim"
    action [:enable, :start]
    # The abiquo-aim script hardly ever returns 0 :(
    ignore_failure true
end
