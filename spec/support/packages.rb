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

def stub_package_commands(packages)
  abiquo = double('abiquo')
  installed = double('installed')

  lang = { 'LC_ALL' => Chef::Config[:internal_locale], 'LANGUAGE' => Chef::Config[:internal_locale], 'LANG' => Chef::Config[:internal_locale] }
  stub_const('ENV', lang)

  names_result = packages.join("\n")
  names_result << "\n"
  allow(Mixlib::ShellOut).to receive(:new).with('repoquery --installed \'abiquo-*\' --qf \'%{name}\'', environment: lang).and_return(abiquo)
  allow(abiquo).to receive(:run_command).and_return(nil)
  allow(abiquo).to receive(:live_stream).and_return(nil)
  allow(abiquo).to receive(:live_stream=).and_return(nil)
  allow(abiquo).to receive(:error!).and_return(nil)
  allow(abiquo).to receive(:stdout).and_return(names_result)

  names = packages.join(' ')
  current = packages.map { |p| p + '-0:3.6.1-85.el6.noarch' }.join("\n")
  current << "\n"
  allow(Mixlib::ShellOut).to receive(:new).with("repoquery --installed #{names}", environment: lang).and_return(installed)
  allow(installed).to receive(:run_command).and_return(nil)
  allow(installed).to receive(:live_stream).and_return(nil)
  allow(installed).to receive(:live_stream=).and_return(nil)
  allow(installed).to receive(:error!).and_return(nil)
  allow(installed).to receive(:stdout).and_return(current)

  stub_available_packages(packages, '-0:3.6.3-207.el6.noarch')
end

def stub_available_packages(packages, version)
  lang = { 'LC_ALL' => Chef::Config[:internal_locale], 'LANGUAGE' => Chef::Config[:internal_locale], 'LANG' => Chef::Config[:internal_locale] }

  available = double('available')
  names = packages.join(' ')
  upstream = packages.map { |p| p + version }.join("\n")
  upstream << "\n"

  allow(Mixlib::ShellOut).to receive(:new).with("repoquery #{names}", environment: lang).and_return(available)
  allow(available).to receive(:run_command).and_return(nil)
  allow(available).to receive(:live_stream).and_return(nil)
  allow(available).to receive(:live_stream=).and_return(nil)
  allow(available).to receive(:error!).and_return(nil)
  allow(available).to receive(:stdout).and_return(upstream)
end
