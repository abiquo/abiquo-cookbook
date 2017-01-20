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

describe 'abiquo::install_kvm' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

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
