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
require 'chefspec'
require 'chefspec/berkshelf'
require 'mysql2'

ChefSpec::Coverage.start!

RSpec.configure do |config|
  config.platform = 'centos'
  config.version = '7.6.1804'
  # Avoid warnings caused by http://tickets.chef.io/browse/CHEF-3694
  config.log_level = :error
  config.color = true
  config.formatter = :documentation
end
