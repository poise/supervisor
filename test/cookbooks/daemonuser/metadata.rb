name              "supervisor"
maintainer        "Dave Shawley"
maintainer_email  "daveshawley@gmail.com"
license           "Apache 2.0"
description       "Installs test fixtures for supervisor cookbook."
version           "0.1.0"

recipe "create-fixtures", "Install users & groups to test the cookbook"

depends "python"

%w{ ubuntu debian }.each do |os|
  supports os
end
