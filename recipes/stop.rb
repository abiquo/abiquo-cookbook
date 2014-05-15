# Cookbook Name:: abiquo
# Recipe:: stop
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

Chef::Recipe.send(:include, Abiquo::Packages)

service "abiquo-tomcat" do
    provider Chef::Provider::Service::RedhatNoStatus
    pattern "tomcat"
    start_command "service abiquo-tomcat jpda" if ['abiquo']['tomcat-jpda']
end

installed_services.each do |svc|
    service svc do
        action :stop
    end
end
