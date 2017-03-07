# Copyright 2014,
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

shared_examples 'common::redis' do
  it 'has a redis user with a proper login shell' do
    expect(user('redis')).to exist
    expect(user('redis')).to have_login_shell('/bin/sh')
  end

  it 'has the redis package installed' do
    expect(package('redis')).to be_installed
  end

  it 'has redis running' do
    redisproc = os[:release].to_i < 7 ? 'redis' : 'redis@'
    expect(service("#{redisproc}master")).to be_enabled
    expect(service("#{redisproc}master")).to be_running
    expect(service("#{redisproc}master")).to be_running.under('systemd') if os[:release].to_i >= 7
    expect(port(6379)).to be_listening
  end
end
