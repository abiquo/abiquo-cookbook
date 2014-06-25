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


# TODO: Change this recipe to download the files from the Oracle
# site instead of having them in the cookbook itself

cookbook_file "#{node['java']['java_home']}/lib/security/local_policy.jar" do
    source "local_policy.jar"
    action :create
end

cookbook_file "#{node['java']['java_home']}/lib/security/US_export_policy.jar" do
    source "US_export_policy.jar"
    action :create
end
