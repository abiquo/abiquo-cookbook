# Cookbook Name:: abiquo
# Recipe:: setup_remoteservices
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

unless node['abiquo']['nfs']['location'].nil?
    # Some templates come with this share already configured
    mount node['abiquo']['nfs']['mountpoint'] do
        device "10.60.1.72:/opt/vm_repository"
        fstype "nfs"
        action [:umount, :disable]
    end
    mount node['abiquo']['nfs']['mountpoint'] do
        device node['abiquo']['nfs']['location']
        fstype "nfs"
        action [:enable, :mount]
    end
end

template "/opt/abiquo/tomcat/conf/server.xml" do
    source "server.xml.erb"
    owner "root"
    group "root"
    action :create
    notifies :restart, "service[abiquo-tomcat]"
end

template "/opt/abiquo/config/abiquo.properties" do
    source "abiquo-rs.properties.erb"
    owner "root"
    group "root"
    action :create
    notifies :restart, "service[abiquo-tomcat]"
end

abiquo_wait_for_webapp "virtualfactory" do
    host "localhost"
    port node['abiquo']['tomcat-http-port']
    retries 3   # Retry if Tomcat is still not started
    retry_delay 5
    action :nothing
    subscribes :wait, "service[abiquo-tomcat]"
    only_if { node['abiquo']['wait-for-webapps'] }
end
