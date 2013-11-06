include_recipe 'python'

directory node['supervisor']['install']['virtualenv'] do
  owner 'root'
end

python_virtualenv node['supervisor']['install']['virtualenv'] do
  owner 'root'
  action :create
end
