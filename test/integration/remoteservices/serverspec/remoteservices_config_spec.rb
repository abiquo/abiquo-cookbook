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

describe 'Remote Services configuration' do
  include_examples 'common::config'
  include_examples 'common::redis'
  include_examples 'abiquo::config'
  include_examples 'websockify::config'

  it 'has a redis user with a proper login shell' do
    expect(user('redis')).to exist
    expect(user('redis')).to have_login_shell('/bin/sh')
  end

  it 'has the appliance manager properly configured' do
    expect(file('/opt/abiquo/config/abiquo.properties')).to contain('abiquo.appliancemanager.checkMountedRepository = false')
  end

  it 'has the sudoers file for the nfs plugin' do
    expect(file('/etc/sudoers.d/abiquo-tomcat-nfs')).to contain('tomcat ALL=(ALL) NOPASSWD: /usr/bin/nfs-plugin')
  end
end
