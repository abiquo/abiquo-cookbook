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

describe 'abiquo::install_kvm' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['virtualization']['role'] = 'guest'
    end.converge(described_recipe)
  end
  let(:c6_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '6.5') }

  it 'locks the seabios version on CentOS 7' do
    expect(chef_run).to create_yum_repository('kvm-common').with(
      description: 'Backports for the seabios package',
      baseurl: 'http://buildlogs.centos.org/centos/7/virt/x86_64/kvm-common',
      includepkgs: 'seabios,seabios-bin,seavgabios-bin',
      gpgcheck: false
    )
    expect(chef_run).to install_package('yum-plugin-versionlock')
    expect(chef_run).to install_yum_package('seabios').with(version: '1.7.5-11.el7')
    expect(chef_run).to lock_yum_package('seabios').with(version: '1.7.5-11.el7')

    c6_run.converge(described_recipe)
    expect(c6_run).to_not install_package('yum-plugin-versionlock')
    expect(c6_run).to_not create_yum_repository('kvm-common')
    expect(c6_run).to_not install_yum_package('seabios')
    expect(c6_run).to_not lock_yum_package('seabios')
  end

  %w(qemu-kvm abiquo-aim abiquo-sosreport-plugins).each do |pkg|
    it "installs the #{pkg} package" do
      expect(chef_run).to install_package(pkg)
    end
  end

  it 'creates link if missing' do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('/usr/bin/qemu-system-x86_64').and_return(false)
    expect(chef_run).to create_link('/usr/bin/qemu-system-x86_64')
  end

  it 'does not create link if exists' do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('/usr/bin/qemu-system-x86_64').and_return(true)
    expect(chef_run).to_not create_link('/usr/bin/qemu-system-x86_64')
  end

  it 'configures the rpcbind service' do
    expect(chef_run).to enable_service('rpcbind')
    expect(chef_run).to start_service('rpcbind')
  end
end
