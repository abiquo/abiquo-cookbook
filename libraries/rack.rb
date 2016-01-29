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
    module Rack
      def abq
        @@abq ||= AbiquoAPI.new(
          :abiquo_api_url => new_resource.abiquo_api_url,
          :abiquo_username => new_resource.abiquo_username,
          :abiquo_password => new_resource.abiquo_password
        )
      end

      def lookup_rack_by_name(rack_name, dc_name)
        dc = find_dc(dc_name)
        dc.link(:racks).get.select {|r| r.name.eql? current_resource.name }.first
      end

      def create_abiquo_rack
        dc = find_dc(new_resource.datacenter)
        raise "Could not find DC '#{new_resource.datacenter}'" if dc.nil?

        racks_lnk = dc.link(:racks)
        rack_hash = {
          "vlanIdMin" => new_resource.vlan_min,
          "vlanIdMax" => new_resource.vlan_max,
          "vlanPerVdcReserved" => new_resource.vlan_reserved,
          "nrsq" => new_resource.nrsq,
          "name" => new_resource.name,
          "vlansIdAvoided" => new_resource.vlan_avoided,
          "haEnabled" => new_resource.ha_enabled
        }
        rack = abq.post(racks_lnk, rack_hash, :content => 'application/vnd.abiquo.rack+json',
                                              :accept => 'application/vnd.abiquo.rack+json')
        Chef::Log.info "Rack '#{rack.name}' created."
      end

      def delete_abiquo_rack
        dc = find_dc(current_resource.datacenter)
        raise "Could not find DC '#{current_resource.datacenter}'" if dc.nil?
        
        rack = dc.link(:racks).get.select {|r| r.name.eql? current_resource.name }.first
        rack.delete if rack
        Chef::Log.info "Deleted rack '#{rack.name}'"
      end

      private

      def find_dc(dc_name)
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
    end
  end
end