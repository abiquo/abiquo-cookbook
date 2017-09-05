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

shared_examples 'setup-kvm' do
  it 'creates the /opt/vm_repository directory' do
    expect(chef_run).to create_directory('/opt/vm_repository').with(
      owner: 'root',
      group: 'root'
    )
  end

  it 'renders the libvirt guests file' do
    expect(chef_run).to create_template('/etc/sysconfig/libvirt-guests').with(
      source: 'libvirt-guests.erb',
      owner: 'root',
      group: 'root'
    )
    resource = chef_run.template('/etc/sysconfig/libvirt-guests')
    expect(resource).to notify('service[libvirtd]').to(:restart).delayed
  end

  it 'renders the abiquo-aim file' do
    expect(chef_run).to create_template('/etc/abiquo-aim.ini').with(
      source: 'abiquo-aim.ini.erb',
      owner: 'root',
      group: 'root'
    )
    resource = chef_run.template('/etc/abiquo-aim.ini')
    expect(resource).to notify('service[abiquo-aim]').to(:restart).delayed
  end

  it 'enables and restarts the libvirtd service' do
    expect(chef_run).to enable_service('libvirtd')
  end

  it 'enables and restarts the abiquo-aim service' do
    expect(chef_run).to enable_service('abiquo-aim')
    expect(chef_run).to enable_service('abiquo-aim')
  end
end

describe 'abiquo::setup_kvm' do
  context 'without repo config' do
    cached(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    include_examples 'setup-kvm'

    it 'does not mount the nfs repository by default' do
      expect(chef_run).to_not mount_mount(chef_run.node['abiquo']['nfs']['mountpoint'])
    end
  end

  context 'with repo config' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['abiquo']['nfs']['location'] = '10.60.1.222:/opt/nfs-devel'
      end.converge(described_recipe)
    end

    include_examples 'setup-kvm'

    it 'enables and mounts the nfs repository if configured' do
      expect(chef_run).to mount_mount('/opt/vm_repository').with(
        fstype: 'nfs',
        device: '10.60.1.222:/opt/nfs-devel'
      )
      expect(chef_run).to enable_mount('/opt/vm_repository').with(
        fstype: 'nfs',
        device: '10.60.1.222:/opt/nfs-devel'
      )
    end
  end
end
