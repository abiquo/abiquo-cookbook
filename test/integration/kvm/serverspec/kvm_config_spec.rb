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

require "#{ENV['BUSSER_ROOT']}/../kitchen/data/serverspec_helper"

describe 'KVM configuration' do
  include_examples 'common::config'

  it 'has the aim configuration file' do
    expect(file('/etc/abiquo-aim.ini')).to contain('port = 8889')
    expect(file('/etc/abiquo-aim.ini')).to contain('repository = /opt/vm_repository')
  end

  it 'has the /opt/vm_repository directory' do
    expect(file('/opt/vm_repository')).to be_directory
  end

  it 'has the libvirt configuration file' do
    expect(file('/etc/sysconfig/libvirt-guests')).to exist
  end

  it 'has the centos-openstack-pike repos installed' do
    expect(yumrepo('centos-openstack-pike')).to exist
    expect(yumrepo('centos-openstack-pike')).to be_enabled
    expect(file('/etc/yum.repos.d/CentOS-OpenStack-pike.repo')).to contain('http://mirror.centos.org/centos/7/cloud/$basearch/openstack-pike/')
  end

  it 'has the neutron configuration files' do
    expect(file('/etc/neutron/neutron.conf')).to be_grouped_into('neutron')
    expect(file('/etc/neutron/neutron.conf')).to contain('password = xabiquo')
  end

  it 'has the linuxbridge agent configuration files' do
    expect(file('/etc/neutron/plugin.ini')).to exist
    expect(file('/etc/neutron/plugins/ml2/linuxbridge_agent.ini')).to be_grouped_into('neutron')
    expect(file('/etc/neutron/plugins/ml2/linuxbridge_agent.ini')).to contain('physical_interface_mappings = external:ens3,abq-vlans:ens4')
  end

  it 'has the ml2 agent configuration files' do
    expect(file('/etc/neutron/plugin.ini')).to exist
    expect(file('/etc/neutron/plugins/ml2/ml2_conf.ini')).to be_grouped_into('neutron')
    expect(file('/etc/neutron/plugins/ml2/ml2_conf.ini')).to contain('network_vlan_ranges = abq-vlans:2:4094')
  end
end
