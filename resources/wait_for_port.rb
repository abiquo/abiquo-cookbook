# Cookbook Name:: abiquo
# Resource:: wait_for_port
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

actions :wait

default_action :nothing

attribute :host, kind_of: String, default: 'localhost'
attribute :port, kind_of: Integer
attribute :service, kind_of: String, name_attribute: true
attribute :delay, kind_of: Integer, default: 10
attribute :timeout, kind_of: Integer, default: 5
