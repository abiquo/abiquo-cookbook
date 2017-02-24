# Cookbook Name:: abiquo
# Recipe:: service
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

template '/opt/abiquo/tomcat/conf/server.xml' do
  source 'server.xml.erb'
  owner 'tomcat'
  group 'root'
  action :create
  notifies :restart, 'service[abiquo-tomcat]'
end

template '/opt/abiquo/config/abiquo.properties' do
  source 'abiquo.properties.erb'
  owner 'root'
  group 'root'
  variables(lazy { { properties: node['abiquo']['properties'] } })
  action :create
  notifies :restart, 'service[abiquo-tomcat]'
end

service 'abiquo-tomcat' do
  action [:enable, :start]
end

case node['abiquo']['profile']
when 'server', 'monolithic'
  webapp = 'api'
when 'remoteservices'
  webapp = 'virtualfactory'
when 'v2v'
  webapp = 'bpm-async'
end

if webapp
  abiquo_wait_for_webapp webapp do
    host 'localhost'
    port node['abiquo']['tomcat']['http-port']
    retries 3 # Retry if Tomcat is still not started
    retry_delay 5
    action :nothing
    subscribes :wait, 'service[abiquo-tomcat]'
    only_if { node['abiquo']['tomcat']['wait-for-webapps'] }
  end
end
