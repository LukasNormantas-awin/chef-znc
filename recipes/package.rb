if platform? ["centos", "redhat"]
    package "znc" do
      action :install
    end
else
  raise %W(Package not supported: #{node['platform_family']} (#{node[:platform]}) #{node['platform_version']}).join(' ')
end
