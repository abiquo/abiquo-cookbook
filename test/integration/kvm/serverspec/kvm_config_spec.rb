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

describe 'KVM configuration' do
    it 'has the epel repos installed' do
        expect(file('/etc/yum.repos.d/epel.repo')).to be_file
        expect(file('/etc/yum.repos.d/epel.repo')).to contain("enabled=1")
    end

    it 'has the aim configuration file' do
        expect(file('/etc/abiquo-aim.ini')).to contain('port = 8889')
        expect(file('/etc/abiquo-aim.ini')).to contain('repository = /opt/vm_repository')
    end

    it 'has the libvirt configuration file' do
        expect(file('/etc/sysconfig/libvirt-guests')).to exist
    end
end
