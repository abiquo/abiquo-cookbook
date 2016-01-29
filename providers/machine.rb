# Cookbook Name:: abiquo
# Provider:: machine
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

include Abiquo::API::Machine

use_inline_resources

# Support whyrun
def whyrun_supported?
  true
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do 
      raise "Need to set one of datastore_name or datastore_root!" if @current_resource.datastore_name.nil? and @current_resource.datastore_root.nil?
      create_abiquo_machine
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_abiquo_machine
    end
  else
    Chef::Log.info "#{ @current_resource } does not exists. Can't delete."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::AbiquoMachine.new(@new_resource.name)
  @current_resource.ip(@new_resource.ip)
  @current_resource.port(@new_resource.port)
  @current_resource.ip_service(@new_resource.ip_service)
  @current_resource.type(@new_resource.type)
  @current_resource.user(@new_resource.user)
  @current_resource.password(@new_resource.password)
  @current_resource.datastore_name(@new_resource.datastore_name)
  @current_resource.datastore_root(@new_resource.datastore_root)
  @current_resource.datastore_dir(@new_resource.datastore_dir)
  @current_resource.service_nic(@new_resource.service_nic)
  @current_resource.datacenter(@new_resource.datacenter)
  @current_resource.rack(@new_resource.rack)
  @current_resource.abiquo_username(@new_resource.abiquo_username)
  @current_resource.abiquo_password(@new_resource.abiquo_password)
  @current_resource.abiquo_api_url(@new_resource.abiquo_api_url)

  if lookup_machine_by_ip(@current_resource.ip, @current_resource.datacenter, @current_resource.rack)
    @current_resource.exists = true
  end
end
