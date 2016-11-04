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

def stub_queries
  allow(::Mysql2::Client).to receive(:default_query_options).with(anything).and_return(true)
  mysql = double('mysql')
  allow(::Mysql2::Client).to receive(:new).with(anything).and_return(mysql)
  allow(mysql).to receive(:query)
    .with('select count(*) as count from information_schema.tables where table_name = "DATABASECHANGELOG" and table_schema = "kinton')
    .and_return([{ 'count' => 1 }])
  allow(mysql).to receive(:query)
    .with('select count(*) as count from information_schema.tables where table_name = "DATABASECHANGELOG" and table_schema = "watchtower"')
    .and_return([{ 'count' => 1 }])
end
