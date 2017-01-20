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

describe 'abiquo::kvm_neutron' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'installs the centos-release-openstack-kilo package' do
    expect(chef_run).to install_package('centos-release-openstack-kilo')
  end

  it 'installs the right version of the openstack-neutron package' do
    expect(chef_run).to install_package('openstack-neutron').with(version: '2015.1.4-1.el7')
  end

  %w(openstack-neutron-ml2 openstack-neutron-linuxbridge).each do |pkg|
    it "installs the #{pkg} package" do
      expect(chef_run).to install_package(pkg)
    end
  end

  it 'creates the config file for neutron' do
    expect(chef_run).to create_template('/etc/neutron/neutron.conf').with(
      source: 'neutron.conf.erb',
      owner: 'root',
      group: 'neutron'
    )
    resource = chef_run.template('/etc/neutron/neutron.conf')
    expect(resource).to notify('service[neutron-linuxbridge-agent]').to(:restart).delayed
  end

  it 'creates the config file for neutron linuxbridge plugin' do
    expect(chef_run).to create_template('/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini').with(
      source: 'neutron-linuxbridge.conf.erb',
      owner: 'root',
      group: 'neutron'
    )
    resource = chef_run.template('/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini')
    expect(resource).to notify('service[neutron-linuxbridge-agent]').to(:restart).delayed
  end

  it 'deletes the plugin.ini file if exists' do
    allow(File).to receive(:symlink?).and_call_original
    allow(File).to receive(:symlink?).with('/etc/neutron/plugin.ini').and_return(false)
    chef_run.converge(described_recipe)
    expect(chef_run).to delete_file('/etc/neutron/plugin.ini')
  end

  it 'does not create link if exists' do
    allow(File).to receive(:symlink?).and_call_original
    allow(File).to receive(:symlink?).with('/etc/neutron/plugin.ini').and_return(false)
    chef_run.converge(described_recipe)
    expect(chef_run).to create_link('/etc/neutron/plugin.ini').with(
      to: '/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini'
    )
  end

  it 'restarts the neutron-linuxbridge-agent service' do
    expect(chef_run).to enable_service('neutron-linuxbridge-agent')
    expect(chef_run).to start_service('neutron-linuxbridge-agent')
  end

  it 'loads the br_netfilter kernel module' do
    expect(chef_run).to load_kernel_module('br_netfilter').with(
      onboot: true,
      reload: false
    )
  end

  it 'configures the sysctl properties to filter traffic in bridged interfaces' do
    expect(chef_run).to include_recipe('sysctl')
    expect(chef_run).to apply_sysctl_param('net.bridge.bridge-nf-call-iptables').with(value: 1)
  end
end
