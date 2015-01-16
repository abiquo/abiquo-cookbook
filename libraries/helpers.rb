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

require 'chef/platform'

module Abiquo

    module Platform
        [:service, :cron, :package, :mdadm, :ifconfig].each do |resource_type|
            Chef::Platform.set(
                :platform => :abiquo,
                :resource => resource_type,
                :provider => Chef::Platform.find_provider(:centos, :default, resource_type)
            )
        end
    end

    module Packages
        include Chef::Mixin::ShellOut

        def gpg_key_files
            keys = %w(Abiquo MariaDB RabbitMQ).map do |keyname|
                "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-#{keyname}"
            end
        end
    end
end
