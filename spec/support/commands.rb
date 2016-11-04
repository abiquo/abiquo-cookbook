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

def stub_check_db_pass_command(user, pass, new_pass = '')
  dbpass = double('dbpass')
  passhash = double('passhash')

  lang = { 'LC_ALL' => Chef::Config[:internal_locale], 'LANGUAGE' => Chef::Config[:internal_locale], 'LANG' => Chef::Config[:internal_locale] }
  stub_const('ENV', lang)

  current_pass_query = "select Password from mysql.user where User = \"#{user}\" and Host = \"%\""
  allow(Mixlib::ShellOut).to receive(:new).with("/usr/bin/mysql -B --skip-column-names -e '#{current_pass_query}'", environment: lang).and_return(dbpass)
  allow(dbpass).to receive(:run_command).and_return(nil)
  allow(dbpass).to receive(:live_stream).and_return(nil)
  allow(dbpass).to receive(:live_stream=).and_return(nil)
  allow(dbpass).to receive(:error!).and_return(nil)
  allow(dbpass).to receive(:stdout).and_return(pass)

  new_pass_query = "select PASSWORD(\"#{new_pass}\")"
  allow(Mixlib::ShellOut).to receive(:new).with("/usr/bin/mysql -B --skip-column-names -e '#{new_pass_query}'", environment: lang).and_return(passhash)
  allow(passhash).to receive(:run_command).and_return(nil)
  allow(passhash).to receive(:live_stream).and_return(nil)
  allow(passhash).to receive(:live_stream=).and_return(nil)
  allow(passhash).to receive(:error!).and_return(nil)
  allow(passhash).to receive(:stdout).and_return(new_pass)
end
