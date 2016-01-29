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

if defined?(ChefSpec)
    def wait_abiquo_wait_for_webapp(webapp_name)
        ChefSpec::Matchers::ResourceMatcher.new(:abiquo_wait_for_webapp, :wait, webapp_name)
    end

    def wait_abiquo_wait_for_port(service_name)
        ChefSpec::Matchers::ResourceMatcher.new(:abiquo_wait_for_port, :wait, service_name)
    end

    def create_abiquo_datacenter(dc_name)
        ChefSpec::Matchers::ResourceMatcher.new(:abiquo_datacenter, :create, dc_name)
    end

    def delete_abiquo_datacenter(dc_name)
        ChefSpec::Matchers::ResourceMatcher.new(:abiquo_datacenter, :delete, dc_name)
    end

    def create_abiquo_rack(rack_name)
        ChefSpec::Matchers::ResourceMatcher.new(:abiquo_rack, :create, rack_name)
    end

    def delete_abiquo_rack(rack_name)
        ChefSpec::Matchers::ResourceMatcher.new(:abiquo_rack, :delete, rack_name)
    end

    def create_abiquo_remote_service(rs_uri)
        ChefSpec::Matchers::ResourceMatcher.new(:abiquo_remote_service, :create, rs_uri)
    end

    def delete_abiquo_remote_service(rs_uri)
        ChefSpec::Matchers::ResourceMatcher.new(:abiquo_remote_service, :delete, rs_uri)
    end

    def create_abiquo_public_cloud_region(pcr_name)
        ChefSpec::Matchers::ResourceMatcher.new(:abiquo_public_cloud_region, :create, pcr_name)
    end

    def delete_abiquo_public_cloud_region(pcr_name)
        ChefSpec::Matchers::ResourceMatcher.new(:abiquo_public_cloud_region, :delete, pcr_name)
    end

    def create_abiquo_machine(machine_ip)
        ChefSpec::Matchers::ResourceMatcher.new(:abiquo_machine, :create, machine_ip)
    end

    def delete_abiquo_machine(machine_ip)
        ChefSpec::Matchers::ResourceMatcher.new(:abiquo_machine, :delete, machine_ip)
    end

    def create_abiquo_license(code)
        ChefSpec::Matchers::ResourceMatcher.new(:abiquo_license, :create, code)
    end

    def delete_abiquo_license(code)
        ChefSpec::Matchers::ResourceMatcher.new(:abiquo_license, :delete, code)
    end
end
