# Cookbook Name:: abiquo
# Provider:: download_cert
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
require 'uri'

def whyrun_supported?
  true
end

def sha1_fingerprint(cert)
  x509 = OpenSSL::X509::Certificate.new(cert)
  OpenSSL::Digest::SHA1.new(x509.to_der).to_s
end

use_inline_resources

action :download do
  converge_by("Downloading SSL certificate from #{new_resource.host}") do
    # Check the provided host is not nil.
    # This can happen if for some reason the name
    # of the resource resolves to nil
    if new_resource.host.nil?
      Chef::Log.debug 'abiquo_download_cert :: SSL location not provided. Skipping.'
      new_resource.updated_by_last_action(false)
      return
    end

    uri = URI.parse(new_resource.host)
    ssl_host = uri.host.nil? ? uri.path : uri.host
    ssl_servername = new_resource.server_name.nil? ? ssl_host : new_resource.server_name

    # Get OpenSSL context
    ctx = OpenSSL::SSL::SSLContext.new

    begin
      # Get remote TCP socket
      sock = TCPSocket.new(ssl_host, 443)

      # Pass that socket to OpenSSL
      ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
      ssl.hostname = ssl_servername

      # Establish connection, if possible
      ssl.connect
    rescue => e
      Chef::Log.debug "abiquo_download_cert :: Could not connect to #{ssl_host}!"
      Chef::Log.debug 'abiquo_download_cert :: ' + e.message
      new_resource.updated_by_last_action(false)
      return
    end

    # Get peer certificate and compute the fingerprint
    cert_sha1 = sha1_fingerprint(ssl.peer_cert)

    # Check if the certificate is already downloaded and is the same one
    cert_full_filename = "#{new_resource.file_path}/#{ssl_host}.crt"
    if ::File.exist? cert_full_filename
      cached_sha1 = sha1_fingerprint(File.read(cert_full_filename))
      if cert_sha1 == cached_sha1
        Chef::Log.debug "abiquo_download_cert :: Certificate for #{ssl_host} has already been downloaded. Skipping."
        new_resource.updated_by_last_action(false)
        return
      end
    end

    # Save the cert to disk
    ::FileUtils.mkdir_p(new_resource.file_path)
    ::File.open(cert_full_filename, 'w') do |f|
      f.write(ssl.peer_cert.to_s)
    end

    Chef::Log.debug 'abiquo_download_cert :: Importing the certificate into Java truststore...'
    java_management_truststore_certificate ssl_host do
      file cert_full_filename
      action :import
    end

    new_resource.updated_by_last_action(true)
  end
end
