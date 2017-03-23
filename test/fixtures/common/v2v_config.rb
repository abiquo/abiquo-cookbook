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

shared_examples 'v2v::config' do
  it 'has the ec2 api tools configured' do
    expect(file('/etc/sysconfig/abiquo/ec2-api-tools')).to contain('^EC2_HOME=/opt/aws$')
  end

  it 'has the iSCSI initiator name configured' do
    expect(file('/etc/iscsi/initiatorname.iscsi')).to exist
    expect(file('/etc/iscsi/initiatorname.iscsi')).to contain('InitiatorName=iqn.')
  end

  it 'has the sudoers file for the mechadora' do
    expect(file('/etc/sudoers.d/abiquo-tomcat-mechadora')).to contain('tomcat ALL=(ALL) NOPASSWD: /usr/bin/mechadora')
  end
end
