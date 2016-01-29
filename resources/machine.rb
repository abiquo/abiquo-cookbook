# Cookbook Name:: abiquo
# Resource:: machine
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
# WITHOUT WARRANTIES OR CONDITIONS OF ANY :kind, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

actions :create, :delete

default_action :create

attribute :ip,                    :kind_of => String, :name_attribute => true
attribute :port,                  :kind_of => Fixnum, :required => true
attribute :type,                  :kind_of => String, :required => true
attribute :ip_service,            :kind_of => String, :default => nil
attribute :user,                  :kind_of => String, :default => "root"
attribute :password,              :kind_of => String, :default => "temporal"
attribute :datastore_name,        :kind_of => String
attribute :datastore_root,        :kind_of => String
attribute :datastore_dir,         :kind_of => String
attribute :service_nic,           :kind_of => String, :required => true
attribute :datacenter,            :kind_of => String, :required => true
attribute :rack,                  :kind_of => String, :required => true
attribute :abiquo_username,       :kind_of => String, :required => true
attribute :abiquo_password,       :kind_of => String, :required => true
attribute :abiquo_api_url,        :kind_of => String, :required => true

attr_accessor :exists
