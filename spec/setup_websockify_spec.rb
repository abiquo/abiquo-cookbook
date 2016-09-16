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
            node.set['abiquo']['certificate']['common_name'] = 'test.local'
        end
    end

    before do
        stub_certificate_files("/etc/pki/abiquo/test.local.crt","/etc/pki/abiquo/test.local.key")
        stub_command('/usr/sbin/httpd -t').and_return(true)
    end

    it 'renders websockify service script' do
        chef_run.converge('apache2::default', 'abiquo::install_websockify', described_recipe, 'abiquo::service')
        expect(chef_run).to create_template('/etc/init.d/websockify').with(
            :source => 'websockify.erb',
            :owner => 'root',
            :group => 'root'
        )
    end

    it 'configures the websockify cron task' do
        chef_run.converge('abiquo::install_websockify', described_recipe, 'abiquo::service')
        expect(chef_run).to create_file("/etc/cron.d/novnc_tokens").with(
            :content  => "* * * * * root /opt/websockify/novnc_tokens.rb -a #{chef_run.node['abiquo']['websockify']['api_url']} -u #{chef_run.node['abiquo']['websockify']['user']} -p #{chef_run.node['abiquo']['websockify']['pass']} -f /opt/websockify/config.vnc",
            :owner    => 'root',
            :group    => 'root',
            :mode     => '0644'
        )
    end

    it 'creates the haproxy instance' do
        chef_run.converge('abiquo::install_websockify', described_recipe, 'abiquo::service')
        expect(chef_run).to create_haproxy_instance('haproxy')
    end
end
