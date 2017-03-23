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

shared_examples 'abiquo::config' do
  it 'has tomcat properly configured' do
    expect(file('/opt/abiquo/tomcat/conf/server.xml')).to contain('<Listener className="com.abiquo.listeners.AbiquoConfigurationListener"/>')
    expect(file('/opt/abiquo/tomcat/conf/server.xml')).to be_owned_by('tomcat')
  end

  it 'has the abiquo properties file' do
    expect(file('/opt/abiquo/config/abiquo.properties')).to exist
  end

  if os[:release].to_i >= 7
    it 'has the abiquo server environment configured' do
      expect(file('/etc/sysconfig/abiquo/abiquo-tomcat')).to contain('^CATALINA_HOME=/opt/abiquo/tomcat$')
      expect(file('/etc/sysconfig/abiquo/abiquo-tomcat')).to contain('^CATALINA_BASE=/opt/abiquo/tomcat$')
      expect(file('/etc/sysconfig/abiquo/abiquo-tomcat')).to contain('^CATALINA_PID=/opt/abiquo/tomcat/work/catalina.pid$')
      expect(file('/etc/sysconfig/abiquo/abiquo-tomcat')).to contain('^JAVA_HOME=')
      expect(file('/etc/sysconfig/abiquo/abiquo-tomcat')).to contain('^JAVA_OPTS=')
      expect(file('/etc/sysconfig/abiquo/abiquo-tomcat')).to contain('^CATALINA_OPTS=')
    end
  end
end
