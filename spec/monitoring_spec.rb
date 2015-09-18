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

describe 'abiquo::monitoring' do
    let(:chef_run) do
        ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
            node.set['cassandra']['config']['cluster_name'] = 'abiquo'
        end.converge(described_recipe)
    end
    let(:pkg) { "kairosdb-#{chef_run.node['abiquo']['kairosdb']['version']}-#{chef_run.node['abiquo']['kairosdb']['release']}.rpm" }
    let(:url) { "https://github.com/kairosdb/kairosdb/releases/download/v#{chef_run.node['abiquo']['kairosdb']['version']}/#{pkg}" }

    it 'downloads the kairosdb package' do
        expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/#{pkg}").with({
            :source => url
        })
    end

    it 'installs the kairosdb package' do
        expect(chef_run).to install_package('kairosdb').with({
            :source => "#{Chef::Config[:file_cache_path]}/#{pkg}"
        })
    end

    it 'renders the kairosdb configuration file' do
        expect(chef_run).to create_template('/opt/kairosdb/conf/kairosdb.properties').with(
            :source => 'kairosdb.properties.erb',
            :owner => 'root',
            :group => 'root'
        )
    end

    it 'installs the jdk package' do
        expect(chef_run).to install_package('jdk')
    end

    it 'configures the java alternatives' do
        expect(chef_run).to set_java_alternatives('set default jdk8').with({
            :java_location => '/usr/java/default',
            :bin_cmds => ['java', 'javac']
        })
    end

    it 'includes the cassandra recipe' do
        expect(chef_run).to include_recipe('cassandra-dse')
    end

    it 'configures the firewall' do
        expect(chef_run).to permissive_selinux_state('SELinux Permissive')
        expect(chef_run).to include_recipe('iptables')
        expect(chef_run).to enable_iptables_rule('firewall-monitoring')
    end

    it 'declares the kairosdb service' do
        resource = chef_run.find_resource(:service, 'kairosdb')
        expect(resource).to do_nothing
    end

    it 'reboots kairosdb when cassandra is started' do
        expect(chef_run).to wait_abiquo_wait_for_port('cassandra').with({
            :port => chef_run.node['cassandra']['rpc_port'].to_i
        })
        resource = chef_run.find_resource(:abiquo_wait_for_port, 'cassandra')
        expect(resource).to notify('service[kairosdb]').to(:restart).delayed
    end
end
