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

def stub_certificate_files(cert, _key)
  crt = double('cert')
  allow(::File).to receive(:open).with(cert, any_args).and_return(crt)
  allow(::File).to receive(:open).with(any_args).and_call_original
  allow(crt).to receive(:read).and_return('randomstring')
end
