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

describe 'abiquo::setup_websockify' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['abiquo']['profile'] = 'websockify'
      node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    end
  end
  let(:c6_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '6.5') }

  before do
    stub_certificate_files('/etc/pki/abiquo/fauxhai.local.crt', '/etc/pki/abiquo/fauxhai.local.key')
    stub_command('/usr/sbin/httpd -t').and_return(true)
  end

  it 'renders websockify service script' do
    chef_run.converge('apache2::default', 'abiquo::install_websockify', described_recipe, 'abiquo::service')
    expect(chef_run).to create_template('/etc/sysconfig/websockify').with(
      source: 'rhel/7/conf-websockify.erb',
      owner: 'root',
      group: 'root'
    )

    c6_run.converge('apache2::default', 'abiquo::install_websockify', described_recipe, 'abiquo::service')
    expect(c6_run).to create_template('/etc/init.d/websockify').with(
      source: 'websockify.erb',
      owner: 'root',
      group: 'root'
    )
  end

  it 'renders websockify plugin credential files' do
    chef_run.converge('apache2::default', 'abiquo::install_websockify', described_recipe, 'abiquo::service')
    expect(chef_run).to create_template('/opt/websockify/abiquo.cfg').with(
      source: 'ws_abiquo.cfg.erb',
      owner: 'root',
      group: 'root'
    )
  end

  it 'creates the haproxy instance' do
    chef_run.converge('abiquo::install_websockify', described_recipe, 'abiquo::service')
    expect(chef_run).to create_haproxy_instance('haproxy')
  end
end
