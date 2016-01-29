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

module Abiquo
  module API
    module Datacenter
      def abq
        @@abq ||= AbiquoAPI.new(
          :abiquo_api_url => new_resource.abiquo_api_url,
          :abiquo_username => new_resource.abiquo_username,
          :abiquo_password => new_resource.abiquo_password
        )
      end

      def lookup_dc_by_name(dc_name)
        l = AbiquoAPI::Link.new(
          :href => '/api/admin/datacenters',
          :type => 'application/vnd.abiquo.datacenters+json',
          :client => abq
        )

        dcs = l.get
        if dcs.size > 0
          dcs.select {|d| d.name.eql? dc_name }.first
        else
          nil
        end
      end

      def create_abiquo_dc
        # Create DC
        l = AbiquoAPI::Link.new(
          :href => '/api/admin/datacenters',
          :type => 'application/vnd.abiquo.datacenters+json',
        )

        dc = {
          "name" => new_resource.name,
          "location" => new_resource.location
        }
        
        dc = abq.post(l, dc, :content => 'application/vnd.abiquo.datacenter+json',
                                       :accept => 'application/vnd.abiquo.datacenter+json')
        Chef::Log.info "Datacenter #{new_resource.name} created."
      end

      def delete_abiquo_dc
        l = AbiquoAPI::Link.new(
          :href => '/api/admin/datacenters',
          :type => 'application/vnd.abiquo.datacenters+json',
          :client => abq
        )

        dcs = l.get
        if dcs.select {|d| d.name.eql? current_resource.name }.first
          dcs.select {|d| d.name.eql? current_resource.name }.first.delete
        end
      end
    end
  end
end