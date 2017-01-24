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

describe 'abiquo::install_websockify' do
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

  %w(libxml2 libxslt).each do |pkg|
    it "installs the #{pkg} package" do
      chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
      expect(chef_run).to install_package(pkg)
    end
  end

  it 'installs the abiquo-websockify abiquo package' do
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    expect(chef_run).to install_package('abiquo-websockify')
  end

  it 'enables the websockify service' do
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    expect(chef_run).to enable_service('websockify')
    expect(chef_run).to start_service('websockify')
  end

  it 'includes the certificate recipe' do
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    expect(chef_run).to include_recipe('abiquo::certificate')
  end

  it 'installs haproxy' do
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    expect(chef_run).to include_recipe('haproxy-ng::install')
    expect(chef_run).to include_recipe('haproxy-ng::service')
  end

  it 'sets up the haproxy frontend' do
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    expect(chef_run).to create_haproxy_frontend('public').with(
      bind: "#{chef_run.node['abiquo']['haproxy']['address']}:#{chef_run.node['abiquo']['haproxy']['port']} ssl crt #{chef_run.node['abiquo']['haproxy']['certificate']}",
      default_backend: 'ws',
      config: ['timeout client 3600s']
    )
  end

  it 'sets up the haproxy backend' do
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    expect(chef_run).to create_haproxy_backend('ws').with(
      balance: 'source',
      servers: [
        { 'name' => 'websockify1',
          'address' => chef_run.node['abiquo']['websockify']['address'],
          'port' => chef_run.node['abiquo']['websockify']['port'],
          'config' => 'weight 1 maxconn 1024 check' }
      ],
      config: [
        'timeout queue 3600s',
        'timeout server 3600s',
        'timeout connect 3600s'
      ]
    )
  end
end
