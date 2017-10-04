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
require_relative 'support/commands'
require_relative 'support/stubs'

shared_examples 'packages' do
  it 'changes selinux to permissive' do
    expect(chef_run).to permissive_selinux_state('SELinux Permissive')
  end

  it 'installs the cronie package and enables crond service' do
    expect(chef_run).to install_package('cronie')
    expect(chef_run).to enable_service('crond')
    expect(chef_run).to start_service('crond')
  end
end

shared_examples 'includes' do |profile|
  it "includes the recipes for the #{profile} profile" do
    expect(chef_run).to include_recipe('abiquo::repository')
    expect(chef_run).to include_recipe("abiquo::install_#{profile}")
    expect(chef_run).to include_recipe("abiquo::setup_#{profile}")
  end

  it "configures the #{profile} firewall" do
    expect(chef_run).to include_recipe('iptables')
    expect(chef_run).to enable_iptables_rule('firewall-common')
    expect(chef_run).to enable_iptables_rule("firewall-#{profile}")
  end
end

describe 'abiquo::default' do
  before do
    stub_certificate_files('/etc/pki/abiquo/fauxhai.local.crt', '/etc/pki/abiquo/fauxhai.local.key')
    stub_command('/usr/sbin/httpd -t').and_return(true)
    stub_command('rabbitmqctl list_users | egrep -q \'^abiquo.*\'').and_return(false)
  end

  %w(monolithic server v2v remoteservices kvm monitoring frontend).each do |profile|
    context "when #{profile}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
          node.set['abiquo']['profile'] = profile
          node.set['cassandra']['config']['cluster_name'] = 'abiquo'
          node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
        end.converge(described_recipe)
      end

      include_examples 'packages'
      include_examples 'includes', profile
    end
  end
end
