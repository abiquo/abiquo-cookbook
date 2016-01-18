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

describe 'abiquo::certificate' do
    let(:chef_run) do
        ChefSpec::SoloRunner.new do |node|
            node.set['selfsigned_certificate']['destination'] = '/tmp/'
        end.converge(described_recipe)
    end

    it 'includes the selfsigned_certificate recipe' do
        expect(chef_run).to include_recipe('selfsigned_certificate::default')
    end

    it 'reloads the apache service' do
        expect(chef_run).to reload_service('apache2')
    end

    it 'installs the certificate in the java trust store' do
        expect(chef_run).to import_java_management_truststore_certificate('abiquo').with(
            :file => '/tmp/server.crt'
        )
    end

    it 'disables further certificate install' do
        chef_run.converge(described_recipe)
        expect(chef_run.node['abiquo']['certificate']['install']).to eq(false)
    end
end
