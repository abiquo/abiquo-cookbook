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
  it 'has crond running' do
    expect(service('crond')).to be_enabled
    expect(service('crond')).to be_running
  end

  it 'has mysql running' do
    expect(service('mysql')).to be_enabled
    expect(service('mysql')).to be_running
    expect(port(3306)).to be_listening
  end

  it 'has rabbitmq running' do
    expect(service('rabbitmq-server')).to be_enabled
    expect(service('rabbitmq-server')).to be_running
    expect(port(5672)).to be_listening
  end

  it 'has redis running' do
    redisproc = os[:release].to_i < 7 ? 'redis' : 'redis@'
    expect(service("#{redisproc}master")).to be_enabled
    expect(service("#{redisproc}master")).to be_running
    expect(service("#{redisproc}master")).to be_running.under('systemd') if os[:release].to_i >= 7
    expect(port(6379)).to be_listening
  end

  it 'has rpcbind running' do
    expect(service('rpcbind')).to be_enabled
    expect(service('rpcbind')).to be_running
  end

  it 'has apache running' do
    expect(service('httpd')).to be_enabled
    expect(service('httpd')).to be_running
    expect(port(80)).to be_listening
    expect(port(443)).to be_listening
  end

  it 'has tomcat running' do
    expect(service('abiquo-tomcat')).to be_enabled
    expect(service('abiquo-tomcat')).to be_running
    expect(port(8009)).to be_listening
    expect(port(8010)).to be_listening
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
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 8009 -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 8010 -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 5672 -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 3306 -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 41337 -j ACCEPT')
    expect(iptables).to have_rule('-P INPUT DROP')

    # Cannot use have_rule with comma
    expect(command('iptables -S | grep -- "-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT"').exit_status).to eq 0
  end
end
