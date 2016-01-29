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
    module PublicCloudRegion
      def abq
        @@abq ||= AbiquoAPI.new(
          :abiquo_api_url => new_resource.abiquo_api_url,
          :abiquo_username => new_resource.abiquo_username,
          :abiquo_password => new_resource.abiquo_password
        )
      end

      def lookup_pcr_by_name(pcr_name)
        l = AbiquoAPI::Link.new(
          :href => '/api/admin/publiccloudregions',
          :type => 'application/vnd.abiquo.publiccloudregions+json',
          :client => abq
        )

        pcrs = l.get
        if pcrs.size > 0
          pcrs.select {|d| d.name.eql? pcr_name }.first
        else
          nil
        end
      end

      def create_abiquo_pcr
        # Create DC
        l = AbiquoAPI::Link.new(
          :href => '/api/admin/publiccloudregions',
          :type => 'application/vnd.abiquo.publiccloudregions+json',
        )

        region_lnk = lookup_region(new_resource.cloud_provider, new_resource.region)

        pcr = {
          "name" => new_resource.name,
          "provider" => new_resource.cloud_provider,
          "links" => [ region_lnk ]
        }
        
        pcr = abq.post(l, pcr, :content => 'application/vnd.abiquo.publiccloudregion+json',
                                       :accept => 'application/vnd.abiquo.publiccloudregion+json')
        Chef::Log.info "Public Cloud Region '#{new_resource.name}' created."
      end

      def delete_abiquo_pcr
        l = AbiquoAPI::Link.new(
          :href => '/api/admin/publiccloudregions',
          :type => 'application/vnd.abiquo.publiccloudregions+json',
          :client => abq
        )

        pcrs = l.get
        if pcrs.select {|d| d.name.eql? current_resource.name }.first
          pcrs.select {|d| d.name.eql? current_resource.name }.first.delete
        end
      end

      private

      def lookup_region(provider_name, region_name)
        # Lookup provider
        l = AbiquoAPI::Link.new(
          :href => '/api/config/hypervisortypes',
          :type => 'application/vnd.abiquo.hypervisortypes+json',
          :client => abq
        )

        htypes = l.get
        provider = htypes.select {|h| h.name.eql? provider_name }.first
        raise "Provider '#{provider_name}' does not exists!" if provider.nil?

        # Lookup region
        regions = provider.link(:regions).get
        region = regions.select {|r| r.name.eql? region_name }.first
        raise "Region '#{region_name}' does not exist for provider '#{provider_name}'!" if region.nil?

        region_lnk = region.link(:self).clone
        region_lnk.rel = 'region'
        region_lnk.to_hash
      end
    end
  end
end