#modified by Lockheed martin 19feb2013
name              "supervisor"
maintainer        "Noah Kantrowitz"
maintainer_email  "noah@opscode.com"
license           "Apache 2.0"
description       "Installs supervisor and provides resources to configure services"
version           "0.5.1"  #tracks to github version 0.4.6

recipe "supervisor", "Installs and configures supervisord"



%w{ ubuntu debian redhat }.each do |os|
  supports os
end
