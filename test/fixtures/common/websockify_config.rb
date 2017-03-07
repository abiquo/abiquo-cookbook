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

shared_examples 'websockify::config' do
  it 'has websockify service script configured' do
    config_file = os[:release].to_i == 6 ? '/etc/init.d/websockify' : '/etc/sysconfig/websockify'
    expect(file(config_file)).to contain('WEBSOCKIFY_PORT=41338')
    expect(file(config_file)).to contain('LOG_FILE=/var/log/websockify')
  end

  it 'has the config file for the websockify plugin' do
    expect(file('/opt/websockify/abiquo.cfg')).to contain('[websockify]')
    expect(file('/opt/websockify/abiquo.cfg')).to contain('ssl_verify = false')
    expect(file('/opt/websockify/abiquo.cfg')).to contain('api_user = admin')
    expect(file('/opt/websockify/abiquo.cfg')).to contain('api_pass = xabiquo')
  end
end
