# Cookbook Name:: abiquo
# Recipe:: install_server
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

include_recipe "apache2"
include_recipe "apache2::mod_proxy_ajp"
include_recipe "apache2::mod_ssl"

%w{liquibase jdk libxslt libxml2}.each do |pkg|
    package pkg do
        action :install
    end
end

include_recipe "java::oracle_jce"
include_recipe "abiquo::install_ext_services" if node['abiquo']['install_ext_services']

%w{server sosreport-plugins tutorials websockify}.each do |pkg|
    package "abiquo-#{pkg}" do
        action :install
    end
end

service 'websockify' do
    action [:enable, :start]
end

file "/etc/cron.d/novnc_tokens" do
    owner "root"
    group "root"
    mode  "0644"
    action :create
end

include_recipe "abiquo::certificate"

web_app "abiquo" do
    template "abiquo.conf.erb"
    server_name node['abiquo']['certificate']['common_name']
    cert_file node['abiquo']['certificate']['file']
    key_file node['abiquo']['certificate']['key_file']
    ca_file node['abiquo']['certificate']['ca_file']
end

include_recipe "abiquo::install_database"
