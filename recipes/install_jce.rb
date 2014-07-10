# Cookbook Name:: abiquo
# Recipe:: install_jce
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

cookbook_file "#{node['java']['java_home']}/lib/security/local_policy.jar" do
    source "java#{node['java']['jdk_version']}/local_policy.jar"
    action :create
end

cookbook_file "#{node['java']['java_home']}/lib/security/US_export_policy.jar" do
    source "java#{node['java']['jdk_version']}/US_export_policy.jar"
    action :create
end
