# Cookbook Name:: abiquo
# Recipe:: configure
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

api_port = node['abiquo']['http-protocol'] == 'https'? 443 : node['apache']['listen_ports'].first
api_location = "#{node['abiquo']['http-protocol']}://#{node['ipaddress']}:#{api_port}/api"

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

execute "create database" do
    command '/usr/bin/mysql -e "CREATE DATABASE IF NOT EXISTS kinton"'
    only_if { node['abiquo']['installdb'] }
end

execute "install database" do
    command "/usr/bin/mysql kinton </usr/share/doc/abiquo-server/database/kinton-schema.sql"
    only_if { node['abiquo']['installdb'] }
end

ruby_block "configure ui" do
    block do
        # Chef search_file_replace_line is not working. Update the json manually
        uiconfigfile = "/var/www/html/ui/config/client-config.json"
        uiconfig = JSON.parse(File.read(uiconfigfile));
        uiconfig['config.endpoint'] = api_location
        File.write(uiconfigfile, JSON.pretty_generate(uiconfig))
    end
    action :create
end

template "/opt/abiquo/tomcat/conf/server.xml" do
    source "server.xml.erb"
    owner "root"
    group "root"
    action :create
    notifies :restart, "service[abiquo-tomcat]"
end

template "/opt/abiquo/config/abiquo.properties" do
    source "abiquo.properties.erb"
    owner "root"
    group "root"
    action :create
    variables(:apilocation => api_location)
    notifies :restart, "service[abiquo-tomcat]"
end
