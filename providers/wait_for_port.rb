# Cookbook Name:: abiquo
# Provider:: wait_for_port
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
    available = false
    loop do
      Chef::Log.debug "Waiting untile #{new_resource.name} is available..."
      Timeout.timeout(new_resource.timeout) do
        begin
          TCPSocket.new(new_resource.host, new_resource.port).close
          available = true
          break
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error
          available = false
        end
      end
      Chef::Log.debug "Waiting #{new_resource.delay} seconds before retrying..."
      sleep(new_resource.delay) unless available
      break if available
    end
    new_resource.updated_by_last_action(true)
  end
end
