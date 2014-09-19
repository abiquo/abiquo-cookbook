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

unless node['java']['oracle']['accept_oracle_download_terms']
    Chef::Application.fatal!("Attribute node['java']['oracle']['accept_oracle_download_terms'] must be true to download directly from the Oracle site")
end

# Remove the existing policy files as the ones in the downloaded zip may have an older date
# and the ark cookbook won't update them
%w{local_policy US_export_policy}.each do |jar|
    file "#{node['java']['java_home']}/jre/lib/security/#{jar}.jar" do
        action :delete
    end
end

ruby_block "prepare-license-cookie" do
    block do
        Chef::REST::CookieJar.instance["download.oracle.com:80"] = "oraclelicense=accept-securebackup-cookie"
    end
    action :create
end

ark "jce-policy-files" do
    url "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"
    path "#{node['java']['java_home']}/jre/lib/security"
    action :dump
end
