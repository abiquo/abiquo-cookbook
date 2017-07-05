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

describe 'Monitoring services' do
  include_examples 'common::services'

  it 'has the monitoring firewall rules configured' do
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 9160 -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 7000 -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 36638 -j ACCEPT')
  end

  it 'has the cassandra service running' do
    expect(service('cassandra')).to be_enabled
    expect(service('cassandra')).to be_running
    expect(service('cassandra')).to be_running.under('systemd') if os[:release].to_i >= 7
    expect(port(9160)).to be_listening
    expect(port(7000)).to be_listening
  end

  it 'has the kairosdb service running' do
    expect(service('kairosdb')).to be_enabled
    expect(service('kairosdb')).to be_running
    expect(service('kairosdb')).to be_running.under('systemd') if os[:release].to_i >= 7
    expect(port(8080)).to be_listening
  end

  it 'has the delorean service running' do
    expect(service('abiquo-delorean')).to be_enabled
    # This requires an external RabbitMQ, so the start operation will fail in the tests. Just
    # check that the service is enabled.
  end

  it 'has the emmett service running' do
    expect(service('abiquo-emmett')).to be_enabled
    expect(service('abiquo-emmett')).to be_running
    expect(port(36638)).to be_listening
  end
end
