name             "znc"
maintainer       "Trond Arve Nordheim"
maintainer_email "t@binarymarbles.com"
license          "Apache 2.0"
description      "Installs and configures ZNC"
long_description IO.read(File.join(File.dirname(__FILE__), "README.md"))
version          "1.0.0"

%w(debian ubuntu centos redhat).each do |platform|
  supports platform
end

%w(runit oidentd).each do |dependency_name|
  depends dependency_name
end

recipe           "znc", "Installs and configures ZNC"
