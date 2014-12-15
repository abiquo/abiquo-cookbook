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

require 'spec_helper'
require_relative 'support/matchers'

describe 'abiquo::install_remoteservices' do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    it 'removes the DHCP packages' do
        expect(chef_run).to purge_package('dhclient').with(
            :ignore_failure => true
        )
    end

    %w{redis jdk}.each do |pkg|
        it "installs the #{pkg} system package" do
            expect(chef_run).to install_package(pkg)
        end
    end

    %w{abiquo-remote-services abiquo-v2v abiquo-sosreport-plugins}.each do |pkg|
        it "installs the #{pkg} abiquo package" do
            expect(chef_run).to install_package(pkg)
        end
    end

    # The iptables_rule call can't be tested because it is not a LWRP
    # but a definition and does not exist in the resource list

    it 'configures the firewall' do
        expect(chef_run).to permissive_selinux_state('SELinux Permissive')
        expect(chef_run).to include_recipe('iptables')
    end

    %w{rpcbind redis}.each do |svc|
        it "configures the #{svc} service" do
            expect(chef_run).to enable_service(svc)
            expect(chef_run).to start_service(svc)
        end
    end
end
