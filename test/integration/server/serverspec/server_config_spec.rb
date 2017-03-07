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

describe 'Server configuration' do
  include_examples 'common::config'
  include_examples 'common::redis'
  include_examples 'abiquo::config'
  include_examples 'frontend::config'
  include_examples 'server::config'

  it 'has DB properly configured' do
    expect(file('/opt/abiquo/tomcat/conf/Catalina/localhost/api.xml')).to contain('username="abiquo" password="abiquo"')
    expect(file('/opt/abiquo/tomcat/conf/Catalina/localhost/m.xml')).to contain('username="abiquo" password="abiquo"')
  end
end
