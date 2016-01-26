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

describe 'abiquo::default' do
    let(:chef_run) do
        ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
            node.set['cassandra']['config']['cluster_name'] = 'abiquo'
            node.set['abiquo']['certificate']['common_name'] = 'test.local'
        end
    end
    let(:cn) { 'test.local' }
    
    before do
        stub_command('/usr/sbin/httpd -t').and_return(true)
        stub_command("/usr/bin/test -f /etc/pki/abiquo/#{cn}.crt").and_return(true)
        stub_command("/usr/bin/mysql -h localhost -P 3306 -uroot kinton -e 'SELECT 1'").and_return(true)
    end

    it 'changes selinux to permissive' do
        chef_run.converge(described_recipe)
        expect(chef_run).to permissive_selinux_state("SELinux Permissive")
    end

    %w{monolithic server v2v remoteservices kvm}.each do |profile|
        it "includes the recipes for the #{profile} profile" do
            chef_run.node.set['abiquo']['profile'] = profile
            stub_command('/usr/sbin/httpd -t').and_return(true) if profile == 'monolithic'
            chef_run.converge(described_recipe)

            expect(chef_run).to include_recipe('abiquo::repository')
            expect(chef_run).to include_recipe("abiquo::install_#{profile}")
            expect(chef_run).to include_recipe("abiquo::setup_#{profile}")
        end
    end

    it 'includes the recipes for the monitoring profile' do
        chef_run.node.set['abiquo']['profile'] = 'monitoring'
        chef_run.converge(described_recipe)

        expect(chef_run).to include_recipe('abiquo::repository')
        expect(chef_run).to include_recipe('abiquo::monitoring')
    end

    it 'configures the firewall' do
        chef_run.converge(described_recipe)
        expect(chef_run).to include_recipe('iptables')
        expect(chef_run).to enable_iptables_rule('firewall-policy-drop')
        expect(chef_run).to enable_iptables_rule('firewall-abiquo')
    end
end
