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

describe 'abiquo::setup_remoteservices' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    end.converge('abiquo::install_websockify', described_recipe)
  end
  let(:cn) { 'fauxhai.local' }

  before do
    stub_certificate_files('/etc/pki/abiquo/fauxhai.local.crt', '/etc/pki/abiquo/fauxhai.local.key')
    stub_command('/usr/sbin/httpd -t').and_return(true)
    stub_command("/usr/bin/test -f /etc/pki/abiquo/#{cn}.crt").and_return(false)
  end

  it 'does not mount the nfs repository by default' do
    expect(chef_run).to_not mount_mount(chef_run.node['abiquo']['nfs']['mountpoint'])
  end

  it 'enables and mounts the nfs repository if configured' do
    chef_run.node.set['abiquo']['nfs']['location'] = '10.60.1.222:/opt/nfs-devel'
    chef_run.converge('abiquo::install_websockify', described_recipe)
    expect(chef_run).to mount_mount('/opt/vm_repository').with(
      fstype: 'nfs',
      device: '10.60.1.222:/opt/nfs-devel'
    )
    expect(chef_run).to enable_mount('/opt/vm_repository').with(
      fstype: 'nfs',
      device: '10.60.1.222:/opt/nfs-devel'
    )
  end

  it 'includes the service recipe' do
    expect(chef_run).to include_recipe('abiquo::service')
  end

  it 'includes the setup_websockify recipe' do
    expect(chef_run).to include_recipe('abiquo::setup_websockify')
  end
end
