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
    module RemoteService
      def abq
        @@abq ||= AbiquoAPI.new(
          :abiquo_api_url => new_resource.abiquo_api_url,
          :abiquo_username => new_resource.abiquo_username,
          :abiquo_password => new_resource.abiquo_password
        )
      end

      def lookup_remote_service_by_uri(rs_uri)
        l = AbiquoAPI::Link.new(
          :href => '/api/admin/remoteservices',
          :type => 'application/vnd.abiquo.remoteservices+json',
          :client => abq
        )

        rss = l.get
        if rss.size > 0
          rss.select {|r| r.uri.eql? rs_uri }.first
        else
          nil
        end
      end

      def create_abiquo_remote_service
        l = AbiquoAPI::Link.new(
          :href => '/api/admin/remoteservices',
          :type => 'application/vnd.abiquo.remoteservices+json',
        )

        datacenter_lnks = get_datacenters + get_pcrs
        
        rs = {
          "uri" => new_resource.uri,
          "type" => new_resource.type,
          "uuid" => new_resource.uuid,
          "links" => datacenter_lnks
        }
        
        rss = abq.post(l, rs, :content => 'application/vnd.abiquo.remoteservice+json',
                              :accept => 'application/vnd.abiquo.remoteservice+json')
        Chef::Log.info "Remote service '#{new_resource.uri}' created."
      end

      def delete_abiquo_remote_service
        l = AbiquoAPI::Link.new(
          :href => '/api/admin/remoteservices',
          :type => 'application/vnd.abiquo.remoteservices+json',
          :client => abq
        )

        rss = l.get
        if rss.select {|r| r.uri.eql? current_resource.uri }.first
          rss.select {|r| r.uri.eql? current_resource.uri }.first.delete
        end
      end

      private

      def get_datacenters
        datacenter_lnks = []
        dcs = [ new_resource.datacenter ].flatten
        dcs.each do |dc|
          d = AbiquoAPI::Link.new(
            :href => '/api/admin/datacenters',
            :type => 'application/vnd.abiquo.datacenters+json',
            :client => abq
          )

          datacenter = d.get.select {|da| da.name.eql? dc }.first
          if datacenter
            d_lnk = datacenter.link(:edit).clone
            d_lnk.rel = "datacenter"
            datacenter_lnks << d_lnk.to_hash
          end
        end
        datacenter_lnks
      end

      def get_pcrs
        pcr_lnks = []
        pcrs = [ new_resource.datacenter ].flatten
        pcrs.each do |pcr|
          p = AbiquoAPI::Link.new(
            :href => '/api/admin/publiccloudregions',
            :type => 'application/vnd.abiquo.publiccloudregions+json',
            :client => abq
          )

          pcr = p.get.select {|pc| pc.name.eql? pcr }.first
          if pcr
            p_lnk = pcr.link(:edit).clone
            p_lnk.rel = "publiccloudregion"
            pcr_lnks << p_lnk.to_hash
          end
        end
        pcr_lnks
      end
    end
  end
end