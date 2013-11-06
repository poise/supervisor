include_recipe 'python'

group node['supervisor']['install']['admin_group']

user node['supervisor']['install']['daemon_user'] do
  home node['supervisor']['install']['virtualenv']
  group node['supervisor']['install']['admin_group']
  action :create
end

directory node['supervisor']['install']['virtualenv'] do
  owner node['supervisor']['install']['daemon_user']
  group node['supervisor']['install']['admin_group']
end

python_virtualenv node['supervisor']['install']['virtualenv'] do
  owner node['supervisor']['install']['daemon_user']
  action :create
end
