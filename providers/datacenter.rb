# Cookbook Name:: abiquo
# Provider:: datacenter
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

include Abiquo::API::Datacenter

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
      create_abiquo_dc
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_abiquo_dc
    end
  else
    Chef::Log.info "#{ @current_resource } does not exists. Can't delete."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::AbiquoDatacenter.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.location(@new_resource.location)
  @current_resource.abiquo_password(@new_resource.abiquo_password)
  @current_resource.abiquo_username(@new_resource.abiquo_username)
  @current_resource.abiquo_api_url(@new_resource.abiquo_api_url)

  if lookup_dc_by_name(@current_resource.name)
    @current_resource.exists = true
  end
end
