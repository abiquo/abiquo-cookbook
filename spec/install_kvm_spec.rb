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

shared_examples 'kvm' do
  %w(abiquo-aim abiquo-sosreport-plugins).each do |pkg|
    it "installs the #{pkg} package" do
      expect(chef_run).to install_package(pkg)
    end
  end

  it 'configures the rpcbind service' do
    expect(chef_run).to enable_service('rpcbind')
    expect(chef_run).to start_service('rpcbind')
  end
end

describe 'abiquo::install_kvm' do
  context 'when CentOS 7' do
    context 'without qemu link' do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/usr/bin/qemu-system-x86_64').and_return(false)
      end

      cached(:chef_run) do
        ChefSpec::SoloRunner.new do |node|
          node.set['virtualization']['role'] = 'guest'
        end.converge(described_recipe)
      end

      it 'installs the qemu-ev packages on CentOS 7' do
        expect(chef_run).to install_package('centos-release-qemu-ev')
        expect(chef_run).to install_package('qemu-kvm-ev')
        expect(chef_run).to_not install_package('qemu-kvm')
      end

      it 'creates link if missing' do
        expect(chef_run).to create_link('/usr/bin/qemu-system-x86_64')
      end

      include_examples 'kvm'
    end

    context 'with qemu link' do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/usr/bin/qemu-system-x86_64').and_return(true)
      end

      cached(:chef_run) do
        ChefSpec::SoloRunner.new do |node|
          node.set['virtualization']['role'] = 'guest'
        end.converge(described_recipe)
      end

      it 'installs the qemu-ev packages on CentOS 7' do
        expect(chef_run).to install_package('centos-release-qemu-ev')
        expect(chef_run).to install_package('qemu-kvm-ev')
        expect(chef_run).to_not install_package('qemu-kvm')
      end

      it 'does not create link if exists' do
        expect(chef_run).to_not create_link('/usr/bin/qemu-system-x86_64')
      end

      include_examples 'kvm'
    end
  end

  context 'when CentOS 6' do
    context 'without qemu link' do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/usr/bin/qemu-system-x86_64').and_return(false)
      end

      cached(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '6.5').converge(described_recipe) }

      it 'installs regular qemu packages on CentOS 6' do
        expect(chef_run).to_not install_package('centos-release-qemu-ev')
        expect(chef_run).to_not install_package('qemu-kvm-ev')
        expect(chef_run).to install_package('qemu-kvm')
      end

      it 'creates link if missing' do
        expect(chef_run).to create_link('/usr/bin/qemu-system-x86_64')
      end

      include_examples 'kvm'
    end

    context 'with qemu link' do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/usr/bin/qemu-system-x86_64').and_return(true)
      end

      cached(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '6.5').converge(described_recipe) }

      it 'installs regular qemu packages on CentOS 6' do
        expect(chef_run).to_not install_package('centos-release-qemu-ev')
        expect(chef_run).to_not install_package('qemu-kvm-ev')
        expect(chef_run).to install_package('qemu-kvm')
      end

      it 'does not create link if exists' do
        expect(chef_run).to_not create_link('/usr/bin/qemu-system-x86_64')
      end

      include_examples 'kvm'
    end
  end
end
