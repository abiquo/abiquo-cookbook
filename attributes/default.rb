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
default['abiquo']['installdb'] = true
default['abiquo']['license'] = nil

# NFS repository configuration
default['abiquo']['nfs']['mountpoint'] = "/opt/vm_repository"
default['abiquo']['nfs']['location'] = nil  # Change to something like: "127.0.0.1:/opt/vm_repository"

# Yum repository configuration
default['abiquo']['yum']['repository'] = "http://mirror.abiquo.com/abiquo/3.0/os/x86_64"
default['abiquo']['yum']['nightly-repo'] = nil

# RabbitMQ configuration
default['abiquo']['rabbitmq']['host'] = "127.0.0.1"
default['abiquo']['rabbitmq']['user'] = "guest"
default['abiquo']['rabbitmq']['password'] = "guest"
default['abiquo']['rabbitmq']['port'] = 5672

# Redis configuration
default['abiquo']['redis']['host'] = "127.0.0.1"
default['abiquo']['redis']['port'] = 6379

# Mail server configuration
default['abiquo']['mail']['address'] = "127.0.0.1"
default['abiquo']['mail']['user'] = "notifications@abiquo.com"
default['abiquo']['mail']['password'] = nil

# Tomcat configuration 
default['abiquo']['tomcat']['http-port'] = 8009
default['abiquo']['tomcat']['ajp-port'] = 8010
default['abiquo']['tomcat']['wait-for-webapps'] = false

# Configure abiquo KVM
default['abiquo']['kvm']['fullvirt'] = false
default['abiquo']['aim']['port'] = 8889

# Override the Apache proxy configuration
override['apache']['proxy']['order'] = "allow,deny"
override['apache']['proxy']['deny_from']  = "none"
override['apache']['proxy']['allow_from'] = "all"

# Override the default JDK 6 version in the java cookbook
override['java']['jdk_version'] = "8"
override['java']['java_home'] = "/usr/java/default"
override['java']['install_flavor'] = "oracle"
override['java']['oracle']['accept_oracle_download_terms'] = true
