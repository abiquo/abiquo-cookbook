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

describe 'KVM services' do
  it 'has selinux configured as permissive' do
    expect(selinux).to be_permissive
  end

  it 'has the firewall configured' do
    expect(iptables).to have_rule('-A INPUT -i lo -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p icmp -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 8889 -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 16509 -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 16514 -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 5900:5999 -j ACCEPT')
    expect(iptables).to have_rule('-P INPUT DROP')

    # Cannot use have_rule with comma
    expect(command('iptables -S | grep -- "-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT"').exit_status).to eq 0
  end

  it 'has the rpcbind service running' do
    expect(service('rpcbind')).to be_enabled
    expect(service('rpcbind')).to be_running
  end

  it 'has the libvirtd service running' do
    expect(service('libvirtd')).to be_enabled
    expect(service('libvirtd')).to be_running
  end

  it 'has the abiquo-aim service running' do
    expect(service('abiquo-aim')).to be_enabled
    expect(service('abiquo-aim')).to be_running
    expect(port(8889)).to be_listening
  end

  it 'has the linuxbridge agent running' do
    expect(service('neutron-linuxbridge-agent')).to be_enabled
  end

  it 'has loaded the br_nbetfilter kernel module' do
    expect(kernel_module('br_netfilter')).to be_loaded
  end

  it 'has iptables enabled on bridged interfaces' do
    expect(linux_kernel_parameter('net.bridge.bridge-nf-call-iptables').value).to eq 1
  end
end
