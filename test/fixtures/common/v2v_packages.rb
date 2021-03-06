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

shared_examples 'v2v::packages' do
  it 'has the v2v system packages installed' do
    expect(package('ec2-api-tools')).to be_installed
  end

  it 'has the v2v packages installed' do
    expect(package('abiquo-v2v')).to be_installed
  end

  it 'has the iscsi-initiator-utils package installed' do
    expect(package('iscsi-initiator-utils')).to be_installed
  end
end
