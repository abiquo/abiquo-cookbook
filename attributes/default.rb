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
default['abiquo']['nfs']['mountpoint'] = "/opt/vm_repository"
default['abiquo']['nfs']['location'] = nil
# default['abiquo']['nfs']['location'] = "10.60.1.104:/volume1/nfs-devel"
default['abiquo']['installdb'] = true
default['abiquo']['license'] = nil
# default['abiquo']['license'] = "license-code"

default['abiquo']['yum']['repository'] = "http://mirror.abiquo.com/abiquo/3.0/os/x86_64"
# Use this property to configure the yum repository with the nightly packages
default['abiquo']['yum']['nightly-repo'] = nil
#default['abiquo']['yum']['nightly-repo'] = "http://10.60.20.42/master/rpm"

default['abiquo']['redishost'] = "127.0.0.1"
default['abiquo']['rabbitmqhost'] = "127.0.0.1"
default['abiquo']['fullvirt'] = false

# Configure abiquo-tomcat 
default['abiquo']['tomcat-jpda'] = false
default['abiquo']['tomcat-http-port'] = 8009
default['abiquo']['tomcat-ajp-port'] = 8010
default['abiquo']['wait-for-webapps'] = false

# SSL configuration
default['abiquo']['ssl']['certificatefile'] = "/etc/pki/tls/certs/ca.crt"
default['abiquo']['ssl']['keyfile'] = "/etc/pki/tls/private/ca.key"
default['abiquo']['ssl']['keystore'] = "/usr/java/default/jre/lib/security/cacerts"
default['abiquo']['ssl']['keytool'] = "/usr/java/default/jre/bin/keytool"
default['abiquo']['ssl']['storepass'] = "changeit"

# override the default JDK 6 version in the java cookbook
override['java']['jdk_version'] = "7"
