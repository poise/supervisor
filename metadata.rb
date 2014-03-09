name             'supervisor'
maintainer       'Noah Kantrowitz'
maintainer_email 'noah@opscode.com'
license          'Apache 2.0'
description      'Installs supervisor and/or configure supervisor processes'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.4.11'
recipe           'supervisor', 'Installs and configures supervisor'

%w(amazon centos debian fedora redhat smartos ubuntu).each do |os|
  supports os
end

depends 'python'
