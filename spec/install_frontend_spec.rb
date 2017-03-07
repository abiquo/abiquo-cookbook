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

describe 'abiquo::install_frontend' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    end
  end
  let(:cn) { 'fauxhai.local' }

  before do
    stub_certificate_files('/etc/pki/abiquo/fauxhai.local.crt', '/etc/pki/abiquo/fauxhai.local.key')
    stub_command('/usr/sbin/httpd -t').and_return(true)
    stub_command("/usr/bin/test -f /etc/pki/abiquo/#{cn}.crt").and_return(false)
  end

  it 'installs the Apache recipes' do
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    expect(chef_run).to include_recipe('apache2')
    expect(chef_run).to include_recipe('apache2::mod_proxy_ajp')
    expect(chef_run).to include_recipe('apache2::mod_ssl')
  end

  %w(ui tutorials).each do |pkg|
    it "installs the abiquo-#{pkg} abiquo package" do
      chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
      expect(chef_run).to install_package("abiquo-#{pkg}")
    end
  end

  it 'includes the certificate recipe' do
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    expect(chef_run).to include_recipe('abiquo::certificate')
  end

  # The apache webapp calls can't be tested because it is not a LWRP
  # but a definition and does not exist in the resource list

  it 'installs haproxy' do
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    expect(chef_run).to include_recipe('haproxy-ng::install')
    expect(chef_run).to include_recipe('haproxy-ng::service')
  end

  it 'sets up the haproxy frontend' do
    chef_run.node.set['abiquo']['haproxy']['ws_paths'] = { '/somePath' => ['10.10.10.10:41338'], '/someOtherPath' => ['20.20.20.20:41338'] }
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    expect(chef_run).to create_haproxy_frontend('public').with(
      bind: "#{chef_run.node['abiquo']['haproxy']['address']}:#{chef_run.node['abiquo']['haproxy']['port']} ssl crt #{chef_run.node['abiquo']['haproxy']['certificate']}",
      acls: [
        { 'name' => '_somepath', 'criterion' => 'path /somePath' },
        { 'name' => '_someotherpath', 'criterion' => 'path /someOtherPath' }
      ],
      use_backends: [
        { 'backend' => '_somepath', 'condition' => 'if _somepath' },
        { 'backend' => '_someotherpath', 'condition' => 'if _someotherpath' }
      ],
      config: ['timeout client 3600s', 'log global']
    )
  end

  it 'sets up the haproxy backends' do
    chef_run.node.set['abiquo']['haproxy']['ws_paths'] = { '/somePath' => ['10.10.10.10:41338'], '/someOtherPath' => ['20.20.20.20:41338'] }
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')

    expect(chef_run).to create_haproxy_backend('_somepath').with(
      balance: 'source',
      mode: 'http',
      servers: [
        { 'name' => 'websockify0',
          'address' => '10.10.10.10',
          'port' => '41338',
          'config' => 'weight 1 maxconn 1024 check' }
      ],
      config: [
        'log global',
        'timeout queue 3600s',
        'timeout server 3600s',
        'timeout connect 3600s'
      ]
    )

    expect(chef_run).to create_haproxy_backend('_someotherpath').with(
      balance: 'source',
      mode: 'http',
      servers: [
        { 'name' => 'websockify0',
          'address' => '20.20.20.20',
          'port' => '41338',
          'config' => 'weight 1 maxconn 1024 check' }
      ],
      config: [
        'log global',
        'timeout queue 3600s',
        'timeout server 3600s',
        'timeout connect 3600s'
      ]
    )
  end
end
