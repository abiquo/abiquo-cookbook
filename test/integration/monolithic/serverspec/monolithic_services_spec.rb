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

require "#{ENV['BUSSER_ROOT']}/../kitchen/data/serverspec_helper"

describe 'Monolithic services' do
  include_examples 'common::services'
  include_examples 'abiquo::services'
  include_examples 'frontend::services'
  include_examples 'server::services'
  include_examples 'v2v::services'
  include_examples 'guacamole::services'

  it 'has rabbitmq running listening to the ssl port' do
    expect(port(5671)).to be_listening
  end

  it 'has the rabbit ssl firewall rules configured' do
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 5671 -j ACCEPT')
  end
end
