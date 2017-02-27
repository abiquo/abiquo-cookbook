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
  it 'has the epel repos installed' do
    expect(file('/etc/yum.repos.d/epel.repo')).to be_file
    expect(file('/etc/yum.repos.d/epel.repo')).to contain('enabled=1')
  end

  it 'has the yum repositories configured' do
    %w(base updates).each do |repo|
      expect(yumrepo("abiquo-#{repo}")).to exist
      expect(yumrepo("abiquo-#{repo}")).to be_enabled
    end
  end

  it 'has tomcat properly configured' do
    expect(file('/opt/abiquo/tomcat/conf/server.xml')).to contain('<Listener className="com.abiquo.listeners.AbiquoConfigurationListener"/>')
    expect(file('/opt/abiquo/tomcat/conf/server.xml')).to be_owned_by('tomcat')
  end

  it 'has the abiquo properties file' do
    expect(file('/opt/abiquo/config/abiquo.properties')).to exist
  end

  it 'has the appliance manager properly configured' do
    expect(file('/opt/abiquo/config/abiquo.properties')).to contain('abiquo.appliancemanager.checkMountedRepository = false')
  end

  it 'has a redis user with a proper login shell' do
    expect(user('redis')).to exist
    expect(user('redis')).to have_login_shell('/bin/sh')
  end
end
