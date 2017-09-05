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

shared_examples 'setup-websockify' do
  it 'renders websockify plugin credential files' do
    expect(chef_run).to create_template('/opt/websockify/abiquo.cfg').with(
      source: 'ws_abiquo.cfg.erb',
      owner: 'root',
      group: 'root'
    )
  end
end

describe 'abiquo::setup_websockify' do
  before do
    stub_certificate_files('/etc/pki/abiquo/fauxhai.local.crt', '/etc/pki/abiquo/fauxhai.local.key')
    stub_command('/usr/sbin/httpd -t').and_return(true)
  end

  context 'with CentOS 7' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['abiquo']['profile'] = 'websockify'
        node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
      end.converge('apache2::default', 'abiquo::install_websockify', described_recipe, 'abiquo::service')
    end

    include_examples 'setup-websockify'

    it 'renders websockify service script' do
      expect(chef_run).to create_template('/etc/sysconfig/websockify').with(
        source: 'rhel/7/conf-websockify.erb',
        owner: 'root',
        group: 'root'
      )
    end
  end

  context 'with CentOS 6' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.5') do |node|
        node.set['abiquo']['profile'] = 'websockify'
        node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
      end.converge('apache2::default', 'abiquo::install_websockify', described_recipe, 'abiquo::service')
    end

    include_examples 'setup-websockify'

    it 'renders websockify service script' do
      expect(chef_run).to create_template('/etc/init.d/websockify').with(
        source: 'websockify.erb',
        owner: 'root',
        group: 'root'
      )
    end
  end
end
