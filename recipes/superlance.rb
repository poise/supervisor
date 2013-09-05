# Install superlance
# Installs memmon binaries ...
python_pip "superlance" do
  action :upgrade
  version node['supervisor']['superlance_version']
end
