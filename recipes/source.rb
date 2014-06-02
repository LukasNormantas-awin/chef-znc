#
# Cookbook Name:: znc
# Recipe:: source
#
# Copyright 2011-2013, Binary Marbles Trond Arve Nordheim
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
#

include_recipe "build-essential"

if platform? ["centos", "redhat"]
  deps = %w(openssl-devel perl-devel pkgconfig c-ares-devel)
else
  deps = %w(libssl-dev libperl-dev pkg-config libc-ares-dev)
end

deps.each do |package_name|
  package package_name do
    action :install
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/znc-#{node["znc"]["version"]}.tar.gz" do
  source node["znc"]["url"]
  checksum node["znc"]["checksum"]
  mode "0644"
end

bash "build znc" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  tar zxf znc-#{node["znc"]["version"]}.tar.gz
  (cd znc-#{node["znc"]["version"]} && ./configure --enable-extra)
  (cd znc-#{node["znc"]["version"]} && make && make install)
  EOF
  not_if "which znc"
end
