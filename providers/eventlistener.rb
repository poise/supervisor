#
# Author:: Aaron O'Mullan <aaron.omullan@friendco.de>
# Cookbook Name:: supervisor
# Provider:: eventlistener
#
# Copyright:: 2011, Opscode, Inc <legal@opscode.com>
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

action :enable do
  converge_by("Enabling #{new_resource} EventListener") do
    enable_service
  end
end

action :disable do
  converge_by("Disabling #{new_resource} EventListener") do
    disable_service
  end
end

def enable_service
  execute "supervisorctl update" do
    action :nothing
    user "root"
  end

  template "#{node['supervisor']['dir']}/eventlistener_#{new_resource.eventlistener_name}.conf" do
    source "eventlistener.conf.erb"
    cookbook "supervisor"
    owner "root"
    group "root"
    mode "644"
    variables :prog => new_resource
    notifies :run, "execute[supervisorctl update]", :immediately
  end
end

def disable_service
  execute "supervisorctl update" do
    action :nothing
    user "root"
  end

  file "#{node['supervisor']['dir']}/eventlistener_#{new_resource.eventlistener_name}.conf" do
    action :delete
    notifies :run, "execute[supervisorctl update]", :immediately
  end
end
