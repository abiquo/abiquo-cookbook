# Cookbook Name:: abiquo
# Resource:: datacenter
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

attribute :name,                  :kind_of => String, :name_attribute => true
attribute :location,              :kind_of => String, :required => true
attribute :abiquo_username,       :kind_of => String, :required => true
attribute :abiquo_password,       :kind_of => String, :required => true
attribute :abiquo_api_url,        :kind_of => String, :required => true

attr_accessor :exists
