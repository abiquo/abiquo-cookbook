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

describe 'abiquo::setup_kvm' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  it 'creates the /opt/vm_repository directory' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_directory('/opt/vm_repository').with(
      owner: 'root',
      group: 'root'
    )
  end

  it 'does not mount the nfs repository by default' do
    chef_run.converge(described_recipe)
    expect(chef_run).to_not mount_mount(chef_run.node['abiquo']['nfs']['mountpoint'])
  end

  it 'enables and mounts the nfs repository if configured' do
    chef_run.node.set['abiquo']['nfs']['location'] = '10.60.1.222:/opt/nfs-devel'
    chef_run.converge(described_recipe)
    expect(chef_run).to mount_mount('/opt/vm_repository').with(
      fstype: 'nfs',
      device: '10.60.1.222:/opt/nfs-devel'
    )
    expect(chef_run).to enable_mount('/opt/vm_repository').with(
      fstype: 'nfs',
      device: '10.60.1.222:/opt/nfs-devel'
    )
  end

  it 'renders the libvirt guests file' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template('/etc/sysconfig/libvirt-guests').with(
      source: 'libvirt-guests.erb',
      owner: 'root',
      group: 'root'
    )
    resource = chef_run.template('/etc/sysconfig/libvirt-guests')
    expect(resource).to notify('service[libvirtd]').to(:restart).delayed
  end

  it 'renders the abiquo-aim file' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template('/etc/abiquo-aim.ini').with(
      source: 'abiquo-aim.ini.erb',
      owner: 'root',
      group: 'root'
    )
    resource = chef_run.template('/etc/abiquo-aim.ini')
    expect(resource).to notify('service[abiquo-aim]').to(:restart).delayed
  end

  it 'enables and restarts the libvirtd service' do
    chef_run.converge(described_recipe)
    expect(chef_run).to enable_service('libvirtd')
  end

  it 'enables and restarts the abiquo-aim service' do
    chef_run.converge(described_recipe)
    expect(chef_run).to enable_service('abiquo-aim')
    expect(chef_run).to enable_service('abiquo-aim')
  end
end
