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

describe 'abiquo::install_jce' do
    let(:chef_run) do
        ChefSpec::SoloRunner.new do |node|
            node.set['java']['oracle']['accept_oracle_download_terms'] = true
        end.converge(described_recipe)
    end

    it 'deletes existing policy files' do
        expect(chef_run).to delete_file('/usr/java/default/jre/lib/security/local_policy.jar')
        expect(chef_run).to delete_file('/usr/java/default/jre/lib/security/US_export_policy.jar')
    end

    it 'prepares the requests with the license cookie' do
        expect(chef_run).to run_ruby_block('prepare-license-cookie')
    end

    it 'installs the unzip package' do
        expect(chef_run).to install_package('unzip')
    end

    it 'downloads the new policy files' do
        expect(chef_run).to dump_ark('jce-policy-files').with(
            :url => 'http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip',
            :path => '/usr/java/default/jre/lib/security'
        )
    end

    it 'disables further jce install' do
        chef_run.converge(described_recipe)
        expect(chef_run.node['abiquo']['jce']['install']).to eq(false)
    end
end
