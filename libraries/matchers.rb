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

if defined?(ChefSpec)
  def wait_abiquo_wait_for_webapp(webapp_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_wait_for_webapp, :wait, webapp_name)
  end

  def wait_abiquo_wait_for_port(service_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_wait_for_port, :wait, service_name)
  end

  def download_abiquo_download_cert(host_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_download_cert, :download, host_name)
  end

  ## TODO
  # https://github.com/sinfomicien/mysql2_chef_gem/pull/48
  def install_mysql2_chef_gem_mariadb(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql2_chef_gem_mariadb, :install, resource_name)
  end

  # database
  #
  ChefSpec.define_matcher :abiquo_database

  def create_abiquo_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_database, :create, resource_name)
  end

  def drop_abiquo_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_database, :drop, resource_name)
  end

  def query_abiquo_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_database, :query, resource_name)
  end

  # database user
  #
  ChefSpec.define_matcher :abiquo_database_user

  def create_abiquo_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_database_user, :create, resource_name)
  end

  def drop_abiquo_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_database_user, :drop, resource_name)
  end

  def grant_abiquo_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_database_user, :grant, resource_name)
  end

  # mysql database
  #
  ChefSpec.define_matcher :abiquo_mysql_database

  def create_abiquo_mysql_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_mysql_database, :create, resource_name)
  end

  def drop_abiquo_mysql_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_mysql_database, :drop, resource_name)
  end

  def query_abiquo_mysql_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_mysql_database, :query, resource_name)
  end

  # mysql database user
  #
  ChefSpec.define_matcher :abiquo_mysql_database_user

  def create_abiquo_mysql_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_mysql_database_user, :create, resource_name)
  end

  def drop_abiquo_mysql_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_mysql_database_user, :drop, resource_name)
  end

  def grant_abiquo_mysql_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:abiquo_mysql_database_user, :grant, resource_name)
  end
end
