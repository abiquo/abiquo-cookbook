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

# Common properties
default['abiquo']['datacenterId'] = "Abiquo"
default['abiquo']['nfs']['mountpoint'] = "/opt/vm_repository"
default['abiquo']['nfs']['location'] = nil
# default['abiquo']['nfs']['location'] = "10.60.1.104:/volume1/nfs-devel"
default['abiquo']['installdb'] = true

# Use this property to configure the yum repository with the nightly packages
default['abiquo']['nightly-repo'] = nil
#default['abiquo']['nightly-repo'] = "http://10.60.20.42/master/rpm"

# Configure abiquo-tomcat ports
default['abiquo']['http-protocol'] = "http"
default['abiquo']['tomcat-http-port'] = 8009
default['abiquo']['tomcat-ajp-port'] = 8010

# override the default JDK 6 version in the java cookbook
override['java']['jdk_version'] = "7"
