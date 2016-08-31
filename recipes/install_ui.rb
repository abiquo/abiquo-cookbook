# Cookbook Name:: abiquo
# Recipe:: install_ui
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

%w{libxslt libxml2}.each do |pkg|
    package pkg do
        action :install
    end
end

%w{ui tutorials websockify}.each do |pkg|
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
    keepalive node['abiquo']['ui']['keepalive']
    keepalive_requests node['abiquo']['ui']['keepalive_requests']
    keepalive_timeout node['abiquo']['ui']['keepalive_timeout']
end
