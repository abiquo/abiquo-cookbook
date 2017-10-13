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

def import_java_management_truststore_certificate(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:java_management_truststore_certificate, :import, resource_name)
end

def permissive_selinux_state(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:selinux_state, :permissive, resource_name)
end

def lock_yum_package(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:yum_package, :lock, resource_name)
end

def install_mysql2_chef_gem_mariadb(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:mysql2_chef_gem_mariadb, :install, resource_name)
end
