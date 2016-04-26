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
        stub_command("/usr/bin/mysql -h localhost -P 3306 -u root watchtower -e 'SELECT 1'").and_return(false)
        stub_command("/usr/bin/mysql -h localhost -P 3306 -u root kinton -e 'SELECT 1'").and_return(true)
        stub_command("rabbitmqctl list_users | egrep -q '^abiquo.*'").and_return(false)
    end

    it 'changes selinux to permissive' do
        chef_run.converge(described_recipe, 'abiquo::service')
        expect(chef_run).to permissive_selinux_state("SELinux Permissive")
    end

    %w{monolithic server v2v remoteservices kvm monitoring}.each do |profile|
        it "includes the recipes for the #{profile} profile" do
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge(described_recipe, 'abiquo::service')
            expect(chef_run).to include_recipe('abiquo::repository')
            expect(chef_run).to include_recipe("abiquo::install_#{profile}")
            expect(chef_run).to include_recipe("abiquo::setup_#{profile}")
        end

        it "configures the #{profile} firewall" do
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge(described_recipe, 'abiquo::service')
            expect(chef_run).to include_recipe('iptables')
            expect(chef_run).to enable_iptables_rule('firewall-common')
            expect(chef_run).to enable_iptables_rule("firewall-#{profile}")
        end
    end
end
