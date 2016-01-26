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

        def abiquo_packages
            pkgs_cmd = shell_out("repoquery --installed 'abiquo-*' --qf '%{name}'").run_command
            pkgs_cmd_out = pkgs_cmd.stdout.split
            print "OUT : #{pkgs_cmd_out.inspect}"
            pkgs_cmd_out
        end

        def abiquo_update_available
            upgrade = false
            puts "Abiquo PKGs : #{abiquo_packages.inspect}"
            abiquo_packages = ['abiquo-api']
            abiquo_packages.each do |pkg|
                installed_cmd = shell_out("repoquery --installed #{pkg} --qf '%{version}-%{release}'")
                installed = installed_cmd.run_command.stdout
                puts "Installed : #{installed}"
                available_cmd = shell_out("repoquery #{pkg} --qf '%{version}-%{release}'")
                available = available_cmd.run_command.stdout
                puts "Available : #{available}"
                unless installed.eql? available
                    upgrade = true
                    break
                end
            end
            puts "Upgrade : #{upgrade.class}"
            upgrade
        end
    end
end
