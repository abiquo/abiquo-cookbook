# Cookbook Name:: abiquo
# Recipe:: install_redis
#
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
user 'redis' do
  comment 'Redis Server'
  home '/var/lib/redis'
  shell '/bin/sh'
  system true
end

## https://github.com/brianbianco/redisio/issues/345
if node['platform_version'].to_i == 6
  semodule_filename_base = 'redis_sentinel'
  semodule_filepath_base = "#{Chef::Config[:file_cache_path]}/#{semodule_filename_base}"
  semodule_filepath = "#{semodule_filepath_base}.te"

  file semodule_filepath do
    content <<-EOU.gsub(/^\s+/, '')
    module redis_sentinel 1.0;

    require {
        type redis_t;
        type redis_port_t;
        class dir { search };
        class file { read write getattr open };
        class tcp_socket { name_connect };
        attribute file_type;
    }

    type redis_conf_t;

    typeattribute redis_conf_t file_type;

    # Allow redis and redis-sentinel to write to their conf files
    allow redis_t redis_conf_t:file { read write getattr open };
    allow redis_t redis_conf_t:dir { search };

    # Allow redis to make outbound connections to other redis hosts
    allow redis_t redis_port_t:tcp_socket name_connect;
    EOU
    owner 'root'
    group 'root'
    mode '0600'
    notifies :run, "execute[semodule-install-#{semodule_filename_base}]", :immediately
  end

  execute "semodule-install-#{semodule_filename_base}" do
    command "/usr/bin/checkmodule -M -m #{semodule_filepath_base}.te -o #{semodule_filepath_base}.mod && /usr/bin/semodule_package -o #{semodule_filepath_base}.pp -m #{semodule_filepath_base}.mod && /usr/sbin/semodule -i #{semodule_filepath_base}.pp"
    action :nothing
  end
end

include_recipe 'redisio'
include_recipe 'redisio::enable'
