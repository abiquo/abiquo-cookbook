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

require 'json'

module Abiquo
  module API
    module Machine
      def abq
        @@abq ||= AbiquoAPI.new(
          :abiquo_api_url => new_resource.abiquo_api_url,
          :abiquo_username => new_resource.abiquo_username,
          :abiquo_password => new_resource.abiquo_password
        )
      end

      def lookup_machine_by_ip(ip, dc_name, rack_name)
        dc = find_dc(current_resource.datacenter)
        raise "Could not find DC '#{current_resource.datacenter}'" if dc.nil?
        rack = dc.link(:racks).get.select {|r| r.name.eql? rack_name }.first
        raise "Could not find Rack '#{rack_name}'" if rack.nil?
        rack.link(:machines).get.select {|m| m.ip.eql? ip }.first
      end

      def create_abiquo_machine
        dc = find_dc(new_resource.datacenter)
        raise "Could not find DC '#{new_resource.datacenter}'" if dc.nil?
        rack = dc.link(:racks).get.select {|r| r.name.eql? current_resource.rack }.first
        raise "Could not find Rack '#{rack_name}'" if rack.nil?

        # Get Service Network service type:
        stype_lnk = dc.link(:networkservicetypes).get.select {|t| t.name.eql? "Service Network" }.first.link(:edit).clone
        stype_lnk.rel = "networkservicetype"

        # Discover the machine.
        disc_query_params = {
          :user => new_resource.user,
          :password => new_resource.password,
          :hypervisor => new_resource.type,
          :ip => new_resource.ip,
          :port => new_resource.port
        }

        hyp = dc.link(:discover).get(disc_query_params).first

        # Set the network type
        hyp.networkInterfaces['collection'].select {|n| n['name'].eql? new_resource.service_nic }.first['links'] << stype_lnk.to_hash

        # Enable datastore
        if new_resource.datastore_name.nil?
          ds = hyp.datastores['collection'].select {|d| d['rootPath'].eql? new_resource.datastore_root}.first
        else
          ds = hyp.datastores['collection'].select {|d| d['name'].eql? new_resource.datastore_name}.first
        end
        ds['enabled'] = true
        ds['directory'] = new_resource.datastore_dir

        # Set credentials
        hyphash = JSON.parse(hyp.to_json)
        hyphash['user'] = new_resource.user
        hyphash['password'] = new_resource.password

        # Create the host
        machine = abq.post(rack.link(:machines), hyphash, :content => 'application/vnd.abiquo.machine+json',
                                                :accept => 'application/vnd.abiquo.machine+json' )
        Chef::Log.info "Machine '#{machine.name}' created."
      end

      def delete_abiquo_rack
        dc = find_dc(current_resource.datacenter)
        raise "Could not find DC '#{current_resource.datacenter}'" if dc.nil?
        rack = dc.link(:racks).get.select {|r| r.name.eql? current_resource.name }.first
        raise "Could not find Rack '#{rack_name}'" if rack.nil?
        machine = rack.link(:machines).get.select {|m| m.ip.eql? ip }.first
        machine.delete if machine
        Chef::Log.info "Deleted machine '#{machine.name}'"
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