# Cookbook Name:: abiquo
# Recipe:: setup_server
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

template "/var/www/html/ui/config/client-config-custom.json" do
    source "ui-config.json.erb"
    owner "root"
    group "root"
    variables({
        :ui_address_type => node['abiquo']['ui_address_type'],
        :ui_address_type_resolved => node[node['abiquo']['ui_address_type']],
        :ui_address => node['abiquo']['ui_address'],
        :ui_props => node['abiquo']['ui_config']
    })
    action :create
    notifies :restart, "service[apache2]"
end

template "/etc/init.d/websockify" do
    source "websockify.erb"
    owner "root"
    group "root"
    variables({
        :websockify_port => node['abiquo']['websockify']['port'],
        :websockify_key => node['abiquo']['websockify']['key'],
        :websockify_crt => node['abiquo']['websockify']['crt']
    })
    action :create
    notifies :restart, "service[websockify]"
end

include_recipe "abiquo::service"
