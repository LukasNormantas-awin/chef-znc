default["znc"]["version"] = "1.0"
default["znc"]["checksum"] = "50e6e3aacb67cf0a63d77f5031d4b75264cee294"
default["znc"]["url"] = "http://znc.in/releases/znc-#{node["znc"]["version"]}.tar.gz"

default["znc"]["user"] = "znc"
default["znc"]["group"] = "znc"
default["znc"]["users"] = []

default["znc"]["port"] = "6667"
default["znc"]["skin"] = "dark-clouds"
default["znc"]["max_buffer_size"] = 500
default["znc"]["modules"] = {
  "webadmin" => "",
  "adminlog" => "",
  "identfile" => ""
}
