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

begin
  Gem::Specification.find_by_name('abiquo-api')
rescue Gem::LoadError
  require 'rubygems/dependency_installer'
  Gem::DependencyInstaller.new(Gem::DependencyInstaller::DEFAULT_OPTIONS).install('abiquo-api', '0.0.5')
end

require 'serverspec'

set :backend, :exec
