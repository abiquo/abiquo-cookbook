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

describe 'KVM services' do
    it 'has selinux configured as permissive' do
        expect(selinux).to be_permissive
    end

    it 'has the rpcbind service running' do
        expect(service('rpcbind')).to be_enabled
        expect(service('rpcbind')).to be_running
    end

    it 'has the abiquo-aim service running' do
        expect(service('abiquo-aim')).to be_enabled
        expect(service('abiquo-aim')).to be_running
        expect(port(8889)).to be_listening
    end
end



