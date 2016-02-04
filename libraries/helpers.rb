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

    module Packages
        include Chef::Mixin::ShellOut

        def gpg_key_files
            keys = %w(Abiquo MariaDB RabbitMQ CentOS-6).map do |keyname|
                "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-#{keyname}"
            end
            # New signing key for Abiquo 3.2.2
            keys << "file:///etc/pki/rpm-gpg/RPM-GPG-RSA-KEY-Abiquo"
        end
    end

    module Commands
        def mysql_cmd(props)
            mysqlcmd = "/usr/bin/mysql -h #{props['host']}"
            mysqlcmd += " -P #{props['port']}"
            mysqlcmd += " -u #{props['user']}"
            unless props['password'].nil? or props['password'].empty?
                mysqlcmd += " -p #{props['password']}"
            end
            mysqlcmd
        end

        def liquibase_cmd(command, props)
            liquibasecmd = "abiquo-liquibase -h #{props['host']}"
            liquibasecmd += " -P #{props['port']}"
            liquibasecmd += " -u #{props['user']}"
            unless props['password'].nil? or props['password'].empty?
                liquibasecmd += " -p #{props['password']}"
            end
            liquibasecmd += " #{command}"
            liquibasecmd
        end
    end
end
