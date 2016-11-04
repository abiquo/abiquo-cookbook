# Cookbook Name:: abiquo
# Provider:: wait_for_webapp
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

def whyrun_supported?
  true
end

use_inline_resources

action :wait do
  converge_by("Waiting for #{new_resource.name}") do
    http = Net::HTTP.new(new_resource.host, new_resource.port)
    http.read_timeout = new_resource.read_timeout
    http.open_timeout = new_resource.open_timeout
    http.start do |h|
      request = Net::HTTP::Get.new("/#{new_resource.webapp}")
      response = h.request(request)
      Chef::Log.debug "Request returned status: #{response.code}"
    end
    new_resource.updated_by_last_action(true)
  end
end
