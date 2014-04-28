# Cookbook Name:: abiquo
# Provider:: nfs
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

def whyrun_supported?
    true
end

action :configure do
    converge_by("Configuring NFS #{@new_resource.share}") do
        # Some templates come with an old share already configured
        oldshare = @new_resource.oldshare
        mount @new_resource.mountpoint do
            device oldshare
            fstype "nfs"
            action [:umount, :disable]
            not_if { @new_resource.oldshare.nil? }
        end
        mount @new_resource.mountpoint do
            device @new_resource.share
            fstype "nfs"
            action [:enable, :mount]
        end
    end
end
