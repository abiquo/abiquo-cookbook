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

describe 'Websockify services' do
  it 'has crond running' do
    expect(service('crond')).to be_enabled
    expect(service('crond')).to be_running
  end

  it 'has websockify running' do
    expect(service('websockify')).to be_enabled
    expect(service('websockify')).to be_running
    expect(port(41338)).to be_listening.on('127.0.0.1')
  end

  it 'has haproxy running' do
    expect(service('haproxy')).to be_enabled
    expect(service('haproxy')).to be_running
    expect(port(41337)).to be_listening
  end

  it 'has selinux configured as permissive' do
    expect(selinux).to be_permissive
  end

  it 'has the firewall configured' do
    expect(iptables).to have_rule('-A INPUT -i lo -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p icmp -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 41337 -j ACCEPT')
    expect(iptables).to have_rule('-P INPUT DROP')

    # Cannot use have_rule with comma
    expect(command('iptables -S | grep -- "-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT"').exit_status).to eq 0
  end
end
