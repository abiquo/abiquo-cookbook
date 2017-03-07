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

shared_examples 'server::services' do
  it 'has mysql running' do
    expect(service('mysql')).to be_enabled
    # MySQL systemd hack
    if os[:release].to_i < 7
      expect(service('mysql')).to be_running
    else
      expect(command("kill -0 `cat /var/lib/mysql/#{host_inventory[:hostname]}.pid`").exit_status).to eq 0
    end
    expect(port(3306)).to be_listening
  end

  it 'has rabbitmq running' do
    expect(service('rabbitmq-server')).to be_enabled
    expect(service('rabbitmq-server')).to be_running
    expect(port(5672)).to be_listening
  end

  it 'has the server firewall rules configured' do
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 5672 -j ACCEPT')
    expect(iptables).to have_rule('-A INPUT -p tcp -m tcp --dport 3306 -j ACCEPT')
  end
end
