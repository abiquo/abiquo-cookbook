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

describe 'abiquo::setup_ui' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    end
  end

  before do
    stub_command('/usr/sbin/httpd -t').and_return(true)
    stub_certificate_files('/etc/pki/abiquo/fauxhai.local.crt', '/etc/pki/abiquo/fauxhai.local.key')
  end

  it 'renders ui configuration file' do
    chef_run.converge('apache2::default', 'abiquo::install_ui', described_recipe, 'abiquo::service')
    json_settings = Chef::JSONCompat.to_json_pretty(chef_run.node['abiquo']['ui_config'])
    expect(chef_run).to create_file('/var/www/html/ui/config/client-config-custom.json').with(
      content: json_settings,
      owner: 'root',
      group: 'root'
    )
  end
end
