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
require 'digest/sha1'

module Abiquo
  module Search
    def search_websockify(query_str)
      paths = {}
      nodes = Chef::Search::Query.new.search(:node, query_str).first || []
      Chef::Log.info('No nodes returned by the search query') if nodes.count.zero?
      nodes.each do |rnode|
        begin
          if rnode['abiquo']['properties']['abiquo.datacenter.id'].nil? || rnode['abiquo']['websockify']['port'].nil?
            # Skip the host if does not have dc id property and ws port
            Chef::Log.info("Node #{node['hostname']} does not have DC id property or Websockify port set. Skipping.")
            next
          end
        rescue NoMethodError
          Chef::Log.info("Node #{node['hostname']} does not have DC id property or Websockify port set. Skipping.")
          next
        end
        idhash = Digest::SHA1.hexdigest(rnode['abiquo']['properties']['abiquo.datacenter.id'])
        dest = "#{rnode['ipaddress']}:#{rnode['abiquo']['websockify']['port']}"
        paths[idhash] = [dest]
      end
      paths
    end
  end

  module Packages
    include Chef::Mixin::ShellOut

    def abiquo_packages
      pkgs_cmd = shell_out!('repoquery --installed \'abiquo-*\' --qf \'%{name}\'')
      pkgs_cmd.stdout.split
    end

    def abiquo_update_available
      installed_pkgs = abiquo_packages.join(' ')
      installed_cmd = shell_out!("repoquery --installed #{installed_pkgs}")
      installed = installed_cmd.stdout
      available_cmd = shell_out!("repoquery #{installed_pkgs}")
      available = available_cmd.stdout
      !available.eql? installed
    end
  end

  module Commands
    def mysql_cmd(props)
      if props['host'] == 'localhost'
        mysqlcmd = 'mysql'
      else
        mysqlcmd = "mysql -h #{props['host']}"
        mysqlcmd += " -P #{props['port']}"
        mysqlcmd += " -u #{props['user']}"
        unless props['password'].nil? || props['password'].empty?
          mysqlcmd += " -p#{props['password']}"
        end
      end
      mysqlcmd
    end

    def liquibase_cmd(command, props, monitoring = false)
      liquibasecmd = if monitoring
                       "abiquo-watchtower-liquibase -h #{props['host']}"
                     else
                       "abiquo-liquibase -h #{props['host']}"
                     end
      liquibasecmd += " -P #{props['port']}"
      liquibasecmd += " -u #{props['user']}"
      unless props['password'].nil? || props['password'].empty?
        liquibasecmd += " -p #{props['password']}"
      end
      liquibasecmd += " #{command}"
      liquibasecmd
    end
  end
end
