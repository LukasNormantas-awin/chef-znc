#
# Cookbook Name:: znc
# Recipe:: default
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

include_recipe "runit"
include_recipe "oidentd"

# Install ZNC.
include_recipe "znc::source"

# Configure the znc user and group.
group node["znc"]["group"] do
  system true
end
user node["znc"]["user"] do
  system true
  gid node["znc"]["group"]
  shell "/bin/bash"
  home "/etc/znc"
end

# Create the znc directories.
%w(/etc/znc /etc/znc/configs /etc/znc/moddata /etc/znc/moddata/adminlog /etc/znc/moddata/identfile /etc/znc/modules /etc/znc/users).each do |dir|
  directory dir do
    owner node["znc"]["user"]
    group node["znc"]["group"]
    mode "0750"
  end
end

# Generate the ZNC SSL certificate.
execute "make znc certificate" do
  command "znc --makepem -d /etc/znc"
  user node["znc"]["user"]
  group node["znc"]["group"]
  creates "/etc/znc/znc.pem"
end

# Set up the Runit service.
runit_service "znc"
service "znc" do
  supports :reload => true
  reload_command "#{node["runit"]["sv_bin"]} hup #{node["runit"]["service_dir"]}/znc"
end

# znc doesn't like to be automated...this prevents a race condition
# http://wiki.znc.in/Configuration#Editing_config
execute "force-save-znc-config" do
  command "#{node["runit"]["sv_bin"]} 1 #{node["runit"]["service_dir"]}/znc"
  action :run
end

# Prepare log directories for each user.
users = node["znc"]["users"].map do |username|
  data_bag_item("users", username)
end
users.each do |user|
  ["/etc/znc/users/#{user["id"]}", "/etc/znc/users/#{user["id"]}/moddata", "/etc/znc/users/#{user["id"]}/moddata/log"].each do |directory_name|
    directory directory_name do
      owner node["znc"]["user"]
      group user["groups"].first
      mode "0750"
    end
  end
  link "/home/#{user["id"]}/znclogs" do
    to "/etc/znc/users/#{user["id"]}/moddata/log"
  end
end

# Generate ZNC config file.

template "/etc/znc/configs/znc.conf" do
  source "znc.conf.erb"
  owner node["znc"]["user"]
  group node["znc"]["group"]
  mode "0600"
  variables(:users => users)
  notifies :restart, "service[znc]"

  # ZNC overwrites the config file with updated info every now and then, so we have to remove the file before running chef if we want to update it.
  not_if { ::File.exist?("/etc/znc/configs/znc.conf") } 
end
template "/etc/znc/moddata/identfile/.registry" do
  source "identfile-registry.erb"
  owner node["znc"]["user"]
  group node["znc"]["group"]
  mode "0600"
  notifies :restart, "service[znc]"
end
