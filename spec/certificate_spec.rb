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

describe 'abiquo::certificate' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    end.converge('apache2::default', 'abiquo::install_ui', described_recipe, 'abiquo::service')
  end
  let(:cn) { 'fauxhai.local' }

  before do
    stub_command('/usr/sbin/httpd -t').and_return(true)
    stub_certificate_files('/etc/pki/abiquo/fauxhai.local.crt', '/etc/pki/abiquo/fauxhai.local.key')
  end

  it 'creates the /etc/pki/abiquo directory' do
    expect(chef_run).to create_directory('/etc/pki/abiquo')
  end

  it 'creates a self signed certificate' do
    expect(chef_run).to create_ssl_certificate(chef_run.node['abiquo']['certificate']['common_name'])
    resource = chef_run.find_resource(:ssl_certificate, chef_run.node['abiquo']['certificate']['common_name'])
    expect(resource).to notify('service[apache2]').to(:restart).delayed
    expect(resource).to notify("template[#{chef_run.node['abiquo']['certificate']['file']}.haproxy.crt]").to(:create).immediately
    expect(resource).to notify("java_management_truststore_certificate[#{chef_run.node['abiquo']['certificate']['common_name']}]").to(:import).immediately
  end

  it 'creates a cert for haproxy' do
    expect(chef_run).to_not create_template("#{chef_run.node['abiquo']['certificate']['file']}.haproxy.crt")
    resource = chef_run.find_resource(:template, "#{chef_run.node['abiquo']['certificate']['file']}.haproxy.crt")
    expect(resource).to do_nothing
  end

  it 'does not create a self signed cert if "source" is not "self-signed"' do
    chef_run.node.set['abiquo']['certificate']['source'] = 'file'
    chef_run.node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    expect(chef_run).to_not create_ssl_certificate(chef_run.node['abiquo']['certificate']['common_name'])
  end

  it 'creates does not overwrite self signed certificate' do
    allow(::File).to receive(:file?).and_return(true)
    chef_run.node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    resource = chef_run.find_resource(:ssl_certificate, chef_run.node['abiquo']['certificate']['common_name'])
    expect(resource).to do_nothing
  end

  it 'installs the certificate in the java trust store' do
    resource = chef_run.find_resource(:java_management_truststore_certificate, chef_run.node['abiquo']['certificate']['common_name'])
    expect(resource).to do_nothing
    expect(resource).to subscribe_to("ssl_certificate[#{chef_run.node['abiquo']['certificate']['common_name']}]").on(:import).immediately
    expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
  end

  it 'does not install the certificate in the java trust store if only UI is installed' do
    chef_run.node.set['abiquo']['profile'] = 'ui'
    chef_run.node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    resource = chef_run.find_resource(:java_management_truststore_certificate, chef_run.node['abiquo']['certificate']['common_name'])
    expect(resource).to do_nothing
  end

  it 'does not install the certificate in the java trust store if only websockify is installed' do
    chef_run.node.set['abiquo']['profile'] = 'websockify'
    chef_run.node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    chef_run.converge('abiquo::install_websockify', described_recipe, 'abiquo::service')
    resource = chef_run.find_resource(:java_management_truststore_certificate, chef_run.node['abiquo']['certificate']['common_name'])
    expect(resource).to do_nothing
  end

  it 'retrieves cert from API if remoteservices' do
    chef_run.node.set['abiquo']['profile'] = 'remoteservices'
    chef_run.node.set['abiquo']['properties']['abiquo.server.api.location'] = 'https://some.fqdn.org/api'
    chef_run.node.set['abiquo']['certificate']['additional_certs'] = { 'someservice' => 'https://some.fqdn.org' }
    chef_run.node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    chef_run.converge('apache2::default', 'abiquo::install_remoteservices', described_recipe, 'abiquo::service')

    expect(chef_run).to download_abiquo_download_cert('api')
    resource = chef_run.find_resource(:abiquo_download_cert, 'api')
    expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed

    expect(chef_run).to download_abiquo_download_cert('someservice')
    resource = chef_run.find_resource(:abiquo_download_cert, 'someservice')
    expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
  end

  it 'retrieves additional certs if specified' do
    chef_run.node.set['abiquo']['properties']['abiquo.server.api.location'] = 'https://some.apifqdn.org/api'
    chef_run.node.set['abiquo']['certificate']['additional_certs'] = { 'someservice' => 'https://some.fqdn.org' }
    chef_run.node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')

    expect(chef_run).to download_abiquo_download_cert('someservice')
    resource = chef_run.find_resource(:abiquo_download_cert, 'someservice')
    expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
  end
end
