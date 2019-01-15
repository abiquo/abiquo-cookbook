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
require_relative 'support/stubs'

shared_examples 'setup-rs' do
  it 'includes the service recipe' do
    expect(chef_run).to include_recipe('abiquo::service')
  end
end

describe 'abiquo::setup_remoteservices' do
  context 'without nfs config' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['abiquo']['certificate']['common_name'] = 'fauxhai.local'
      end.converge(described_recipe)
    end

    include_examples 'setup-rs'

    it 'does not mount the nfs repository by default' do
      expect(chef_run).to_not mount_mount(chef_run.node['abiquo']['nfs']['mountpoint'])
    end
  end

  context 'with nfs config' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['abiquo']['certificate']['common_name'] = 'fauxhai.local'
        node.normal['abiquo']['nfs']['location'] = '10.60.1.222:/opt/nfs-devel'
      end.converge(described_recipe)
    end

    include_examples 'setup-rs'

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
