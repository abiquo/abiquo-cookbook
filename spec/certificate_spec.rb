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

describe 'abiquo::certificate' do
    let(:chef_run) { ChefSpec::SoloRunner.new do |node|
        node.set['abiquo']['certificate']['common_name'] = 'test.local'
    end.converge('apache2::default',described_recipe,'abiquo::service') }
    let(:cn) { 'test.local' }
    
    before do
        stub_command('/usr/sbin/httpd -t').and_return(true)
    end

    it 'creates the /etc/pki/abiquo directory' do
        expect(chef_run).to create_directory("/etc/pki/abiquo")
    end

    it 'creates a self signed certificate' do
        expect(chef_run).to create_ssl_certificate(chef_run.node['abiquo']['certificate']['common_name'])
        resource = chef_run.find_resource(:ssl_certificate, chef_run.node['abiquo']['certificate']['common_name'])
        expect(resource).to notify('service[apache2]').to(:restart).delayed
    end
    
    it 'creates does not overwrite self signed certificate' do
        allow(::File).to receive(:file?).and_return(true)
        resource = chef_run.find_resource(:ssl_certificate, chef_run.node['abiquo']['certificate']['common_name'])
        expect(resource).to do_nothing
    end

    it 'installs the certificate in the java trust store' do
        resource = chef_run.find_resource(:java_management_truststore_certificate, chef_run.node['abiquo']['certificate']['common_name'])
        expect(resource).to do_nothing
        expect(resource).to subscribe_to("ssl_certificate[#{chef_run.node['abiquo']['certificate']['common_name']}]").on(:import).immediately
        expect(resource).to notify('service[abiquo-tomcat]').to(:start).delayed
    end
end
