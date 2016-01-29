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

require "#{ENV['BUSSER_ROOT']}/../kitchen/data/serverspec_helper"
require 'abiquo-api'
require 'json'

describe 'LWRP tests' do
    let(:abq) { 
        AbiquoAPI.new(:abiquo_api_url => 'http://localhost:8009/api', :abiquo_username => "admin", :abiquo_password => "xabiquo")
    }
    let (:attrib_file) { '/tmp/node_attributes.json' }
    let (:lic_code) { 'aDWNPdzzj9Dd1uUM+kE+dOj/FvO00Z71v6Ux0RCMGd/BgaGeq/Drwgc6xvrC9m9h+gawA+FlyrUoDtoVHqPMXRDsIru5E+GvdY95hZ5zhf45qsg1FnfbuSGN7uXNum/d5Eozgu6ukGSG7GQ9hmp4Ednods1YZr6AZ4SbYmKsxVQeOmg36T04mpF23rtjD4hr3vB3DZz2EZ1nEBHVxETp8PQFmb152RMcG+A5MTQPZFy0TF/xFSsRVFT0TJ/eByszq/R/2ChHoQWOe72+qH52G5VNpmi9Ud/Yt/SHZTxawdfXOpf9LxSdIubpSe5OD0Q58826SVOnv0xA9mS6gbKLWiIBOA+3If0AVscqBU+pWDhYxEmWz+Z/Vc/H1uHPuqTWsJPmvYOxElRIqbVr2dn/+kbSjqwK33tBF1VN3pzfEQahREuTGR1LA3CPqGk9X5fHMGksYMF4P45mij+juNoF7i7kEh5/ULesnqUZEy8Nbq6n/VgsrJ3cXhsluHfO78gvRemEdggmCGYBTfritP/txkjj+YS0T0ToaYLQAXzYmcnC6fKKA8/4gE9CSY64IKrG3zBFC8VdJBCF6FnDhiLwF0ezBUpOwvN+FEY4gDXNMQbPJMU7L6m15AijqVPG8/kHZJcEe+0aARctqmb9Qwcr9+cVEWkDrXcuPC/6T5rtX3M=' }

    it 'creates a JSON file with node attributes' do
        expect(file(attrib_file)).to exist
        expect(file(attrib_file)).to contain(/recipe[abiquo_test::default]/)
    end

    it 'creates an Abiquo license' do
        lics_lnk = AbiquoAPI::Link.new :href => '/api/config/licenses',
                                      :type => 'application/vnd.abiquo.licenses+json',
                                      :client => abq
        lics = lics_lnk.get
        lic = lics.select {|d| d.code.eql? lic_code}.first
        expect(lic).not_to be_nil
        expect(lics.count).to eq(1)
        expect(lic.code).to match(lic_code)
    end

    it 'creates an Abiquo Datacenter' do
        dcs_lnk = AbiquoAPI::Link.new :href => '/api/admin/datacenters',
                                      :type => 'application/vnd.abiquo.datacenters+json',
                                      :client => abq
        dcs = dcs_lnk.get
        dc = dcs.select {|d| d.name.eql? "test dc"}.first
        expect(dc).not_to be_nil
        expect(dcs.count).to eq(1)
        expect(dc.name).to match("test dc")
        expect(dc.location).to match("Somewhere over the rainbows")
    end

    it 'creates an Abiquo rack' do
        dcs_lnk = AbiquoAPI::Link.new :href => '/api/admin/datacenters',
                                      :type => 'application/vnd.abiquo.datacenters+json',
                                      :client => abq
        dcs = dcs_lnk.get
        dc = dcs.select {|d| d.name.eql? 'test dc'}.first
        expect(dc).not_to be_nil
        rack = dc.link(:racks).get.select {|r| r.name.eql? 'test rack' }.first
        expect(rack).not_to be_nil
        expect(rack.name).to match('test rack')
        expect(dc.link(:edit)).not_to be_nil
        expect(rack.link(:datacenter)).not_to be_nil
        expect(rack.link(:datacenter).href).to match(dc.link(:edit).href)
        expect(rack.vlanIdMin).to eq(100)
        expect(rack.vlanIdMax).to eq(150)
        expect(rack.vlansIdAvoided).to match("111")
        expect(rack.vlanPerVdcReserved).to eq(2)
        expect(rack.nrsq ).to eq(1)
        expect(rack.haEnabled).to be_truthy
    end

    it 'creates an Abiquo PCR' do
        pcrs_lnk = AbiquoAPI::Link.new :href => '/api/admin/publiccloudregions',
                                       :type => 'application/vnd.abiquo.publiccloudregions+json',
                                       :client => abq
        pcrs = pcrs_lnk.get
        pcr = pcrs.select {|p| p.name.eql? 'aws eu-west-1'}.first
        expect(pcr).not_to be_nil
        expect(pcrs.count).to eq(1)
        expect(pcr.name).to match('aws eu-west-1')
        expect(pcr.link(:hypervisortype).href.split('/').last).to match('AMAZON')
        expect(pcr.link(:region).title).to match('eu-west-1')
    end

    it 'creates the "VIRTUAL_SYSTEM_MONITOR" remote service' do
        dcs_lnk = AbiquoAPI::Link.new :href => '/api/admin/datacenters',
                                      :type => 'application/vnd.abiquo.datacenters+json',
                                      :client => abq
        dcs = dcs_lnk.get
        dc = dcs.select {|d| d.name.eql? 'test dc'}.first

        pcrs_lnk = AbiquoAPI::Link.new :href => '/api/admin/publiccloudregions',
                                       :type => 'application/vnd.abiquo.publiccloudregions+json',
                                       :client => abq
        pcrs = pcrs_lnk.get
        pcr = pcrs.select {|p| p.name.eql? 'aws eu-west-1'}.first

        node = JSON.parse(File.read(attrib_file))
        rss_lnk = AbiquoAPI::Link.new :href => '/api/admin/remoteservices',
                                     :type => 'application/vnd.abiquo.remoteservices+json',
                                     :client => abq
        rss = rss_lnk.get
        rs = rss.select {|r| r.type.eql? "VIRTUAL_SYSTEM_MONITOR" }.first
        expect(rs.uri).to match("http://#{node['automatic']['ipaddress']}:8009/vsm")
        expect(rs.uuid).to match('test')
        expect(rs.link(:datacenter).href).to match(dc.link(:edit).href)
        expect(rs.link(:publiccloudregion).href).to match(pcr.link(:edit).href)
    end

    it 'creates the "NODE_COLLECTOR" remote service' do
        dcs_lnk = AbiquoAPI::Link.new :href => '/api/admin/datacenters',
                                      :type => 'application/vnd.abiquo.datacenters+json',
                                      :client => abq
        dcs = dcs_lnk.get
        dc = dcs.select {|d| d.name.eql? 'test dc'}.first

        pcrs_lnk = AbiquoAPI::Link.new :href => '/api/admin/publiccloudregions',
                                       :type => 'application/vnd.abiquo.publiccloudregions+json',
                                       :client => abq
        pcrs = pcrs_lnk.get
        pcr = pcrs.select {|p| p.name.eql? 'aws eu-west-1'}.first

        node = JSON.parse(File.read(attrib_file))
        rss_lnk = AbiquoAPI::Link.new :href => '/api/admin/remoteservices',
                                     :type => 'application/vnd.abiquo.remoteservices+json',
                                     :client => abq
        rss = rss_lnk.get
        rs = rss.select {|r| r.type.eql? "NODE_COLLECTOR" }.first
        expect(rs.uri).to match("http://#{node['automatic']['ipaddress']}:8009/nodecollector")
        expect(rs.uuid).to match('test')
        expect(rs.link(:datacenter).href).to match(dc.link(:edit).href)
        expect(rs.link(:publiccloudregion).href).to match(pcr.link(:edit).href)
    end

    it 'creates the "VIRTUAL_FACTORY" remote service' do
        dcs_lnk = AbiquoAPI::Link.new :href => '/api/admin/datacenters',
                                      :type => 'application/vnd.abiquo.datacenters+json',
                                      :client => abq
        dcs = dcs_lnk.get
        dc = dcs.select {|d| d.name.eql? 'test dc'}.first

        pcrs_lnk = AbiquoAPI::Link.new :href => '/api/admin/publiccloudregions',
                                       :type => 'application/vnd.abiquo.publiccloudregions+json',
                                       :client => abq
        pcrs = pcrs_lnk.get
        pcr = pcrs.select {|p| p.name.eql? 'aws eu-west-1'}.first

        node = JSON.parse(File.read(attrib_file))
        rss_lnk = AbiquoAPI::Link.new :href => '/api/admin/remoteservices',
                                     :type => 'application/vnd.abiquo.remoteservices+json',
                                     :client => abq
        rss = rss_lnk.get
        rs = rss.select {|r| r.type.eql? "VIRTUAL_FACTORY" }.first
        expect(rs.uri).to match("http://#{node['automatic']['ipaddress']}:8009/virtualfactory")
        expect(rs.uuid).to match('test')
        expect(rs.link(:datacenter).href).to match(dc.link(:edit).href)
        expect(rs.link(:publiccloudregion).href).to match(pcr.link(:edit).href)
    end

    it 'creates the "STORAGE_SYSTEM_MONITOR" remote service' do
        dcs_lnk = AbiquoAPI::Link.new :href => '/api/admin/datacenters',
                                      :type => 'application/vnd.abiquo.datacenters+json',
                                      :client => abq
        dcs = dcs_lnk.get
        dc = dcs.select {|d| d.name.eql? 'test dc'}.first

        node = JSON.parse(File.read(attrib_file))
        rss_lnk = AbiquoAPI::Link.new :href => '/api/admin/remoteservices',
                                     :type => 'application/vnd.abiquo.remoteservices+json',
                                     :client => abq
        rss = rss_lnk.get
        rs = rss.select {|r| r.type.eql? "STORAGE_SYSTEM_MONITOR" }.first
        expect(rs.uri).to match("http://#{node['automatic']['ipaddress']}:8009/ssm")
        expect(rs.uuid).to match('test')
        expect(rs.link(:datacenter).href).to match(dc.link(:edit).href)
    end

    it 'creates the "APPLIANCE_MANAGER" remote service' do
        dcs_lnk = AbiquoAPI::Link.new :href => '/api/admin/datacenters',
                                      :type => 'application/vnd.abiquo.datacenters+json',
                                      :client => abq
        dcs = dcs_lnk.get
        dc = dcs.select {|d| d.name.eql? 'test dc'}.first

        node = JSON.parse(File.read(attrib_file))
        rss_lnk = AbiquoAPI::Link.new :href => '/api/admin/remoteservices',
                                     :type => 'application/vnd.abiquo.remoteservices+json',
                                     :client => abq
        rss = rss_lnk.get
        rs = rss.select {|r| r.type.eql? "APPLIANCE_MANAGER" }.first
        expect(rs.uri).to match("https://#{node['name']}:443/am")
        expect(rs.uuid).to match('test')
        expect(rs.link(:datacenter).href).to match(dc.link(:edit).href)
    end

    it 'creates the "BPM_SERVICE" remote service' do
        dcs_lnk = AbiquoAPI::Link.new :href => '/api/admin/datacenters',
                                      :type => 'application/vnd.abiquo.datacenters+json',
                                      :client => abq
        dcs = dcs_lnk.get
        dc = dcs.select {|d| d.name.eql? 'test dc'}.first

        node = JSON.parse(File.read(attrib_file))
        rss_lnk = AbiquoAPI::Link.new :href => '/api/admin/remoteservices',
                                     :type => 'application/vnd.abiquo.remoteservices+json',
                                     :client => abq
        rss = rss_lnk.get
        rs = rss.select {|r| r.type.eql? "BPM_SERVICE" }.first
        expect(rs.uri).to match("http://#{node['automatic']['ipaddress']}:8009/bpm-async")
        expect(rs.uuid).to match('test')
        expect(rs.link(:datacenter).href).to match(dc.link(:edit).href)
    end

    it 'creates the "CLOUD_PROVIDER_PROXY" remote service' do
        pcrs_lnk = AbiquoAPI::Link.new :href => '/api/admin/publiccloudregions',
                                       :type => 'application/vnd.abiquo.publiccloudregions+json',
                                       :client => abq
        pcrs = pcrs_lnk.get
        pcr = pcrs.select {|p| p.name.eql? 'aws eu-west-1'}.first

        node = JSON.parse(File.read(attrib_file))
        rss_lnk = AbiquoAPI::Link.new :href => '/api/admin/remoteservices',
                                     :type => 'application/vnd.abiquo.remoteservices+json',
                                     :client => abq
        rss = rss_lnk.get
        rs = rss.select {|r| r.type.eql? "CLOUD_PROVIDER_PROXY" }.first
        expect(rs.uri).to match("http://#{node['automatic']['ipaddress']}:8009/cpp")
        expect(rs.uuid).to match('test')
        expect(rs.link(:publiccloudregion).href).to match(pcr.link(:edit).href)
    end

    it 'creates an Abiquo machine' do
        node = JSON.parse(File.read(attrib_file))
        dcs_lnk = AbiquoAPI::Link.new :href => '/api/admin/datacenters',
                                      :type => 'application/vnd.abiquo.datacenters+json',
                                      :client => abq
        dcs = dcs_lnk.get
        dc = dcs.select {|d| d.name.eql? 'test dc'}.first
        expect(dc).not_to be_nil
        rack = dc.link(:racks).get.select {|r| r.name.eql? 'test rack' }.first
        machine = rack.link(:machines).get.select {|m| m.ip.eql? node['automatic']['ipaddress'] }.first

        expect(machine).not_to be_nil
        expect(machine.name).to match(node['name'])
        
        ds = machine.datastores['collection'].select {|d| d['enabled'] == true }.first
        expect(ds).not_to be_nil
        expect(ds['rootPath']).to match('/')
        expect(ds['directory']).to match('/var/lib/virt')

        nic = machine.networkInterfaces['collection'].select {|n| not n['links'].empty? }.first
        expect(nic).not_to be_nil
        expect(nic['name']).to match('eth0')
    end
end
