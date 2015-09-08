# Cookbook Name:: abiquo
# Attributes:: abiquo
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

# The profile to install: monolithic, remoteservices or kvm
default['abiquo']['profile'] = "monolithic"

# Common properties
default['abiquo']['datacenterId'] = "Abiquo"
default['abiquo']['license'] = nil

# NFS repository configuration
default['abiquo']['nfs']['mountpoint'] = "/opt/vm_repository"
default['abiquo']['nfs']['location'] = nil  # Change to something like: "127.0.0.1:/opt/vm_repository"

# Yum repository configuration
default['abiquo']['yum']['base-repo'] = "http://mirror.abiquo.com/abiquo/3.6/os/x86_64"
default['abiquo']['yum']['updates-repo'] = "http://mirror.abiquo.com/abiquo/3.6/updates/x86_64"
default['abiquo']['yum']['nightly-repo'] = nil

# Database configuration
default['abiquo']['db']['host'] = "localhost"
default['abiquo']['db']['port'] = 3306
default['abiquo']['db']['user'] = "root"
default['abiquo']['db']['password'] = nil
default['abiquo']['db']['install'] = true
default['abiquo']['db']['upgrade'] = true

# RabbitMQ configuration
default['abiquo']['rabbitmq']['host'] = "127.0.0.1"
default['abiquo']['rabbitmq']['user'] = "guest"
default['abiquo']['rabbitmq']['password'] = "guest"
default['abiquo']['rabbitmq']['port'] = 5672

# Redis configuration
default['abiquo']['redis']['host'] = "127.0.0.1"
default['abiquo']['redis']['port'] = 6379

# Mail server configuration
default['abiquo']['mail']['server'] = "127.0.0.1"
default['abiquo']['mail']['user'] = "notifications@abiquo.com"
default['abiquo']['mail']['password'] = nil

# Tomcat configuration 
default['abiquo']['tomcat']['http-port'] = 8009
default['abiquo']['tomcat']['ajp-port'] = 8010
default['abiquo']['tomcat']['wait-for-webapps'] = false

# Configure abiquo KVM
default['abiquo']['kvm']['fullvirt'] = false
default['abiquo']['aim']['port'] = 8889

# Configure monitoring node
default['abiquo']['cassandra']['cluster_name'] = 'abiquo'
default['abiquo']['kairosdb']['host'] = 'localhost'
default['abiquo']['kairosdb']['port'] = 8080
default['abiquo']['kairosdb']['version'] = '0.9.4'
default['abiquo']['kairosdb']['release'] = '6'

# Override the Apache proxy configuration
override['apache']['proxy']['order'] = "allow,deny"
override['apache']['proxy']['deny_from']  = "none"
override['apache']['proxy']['allow_from'] = "all"

# Override the default java configuration
# TODO: Configure these attributes in a way that they don't have precedence over user config
override['java']['oracle']['accept_oracle_download_terms'] = true
override['java']['java_home'] = "/usr/java/default"
