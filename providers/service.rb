#
# Author:: Noah Kantrowitz <noah@opscode.com>
# Cookbook Name:: supervisor
# Provider:: service
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
  if current_resource.enabled?
    Chef::Log.info "#{new_resource} is already enabled."
  else
    converge_by("Enabling #{ new_resource }") do
      enable_service
  end
end

action :disable do
  if current_resource.enabled?
    converge_by("Disabling #{new_resource}") do
      disable_service
    end
  else
    Chef::Log.info "#{new_resource} is already disabled."
  end
end

action :add do
  converge_by("Creating #{new_resource}") unless ::File.exists?("#{node['supervisor']['dir']}/#{new_resource.service_name}.#{node[:supervisor][:conf][:extension]}") do
    create_config_file
  end
end

action :remove do
  if ::File.exists?("#{node['supervisor']['dir']}/#{new_resource.service_name}.#{node[:supervisor][:conf][:extension]}")
    converge_by("Removing #{new_resource}") do
      execute "supervisorctl update" do
        action :nothing
        user "root"
      end

      file "#{node['supervisor']['dir']}/#{new_resource.service_name}.#{node[:supervisor][:conf][:extension]}" do
        action :delete
        notifies :run, "execute[supervisorctl update]", :immediately
      end
    end
  end
end

action :start do
  create_config_file
  case current_resource.state
  when 'RUNNING'
    Chef::Log.debug "#{ new_resource } is already started."
  when 'STARTING'
    Chef::Log.debug "#{ new_resource } is already starting."
  else
    converge_by("Starting #{ new_resource }") do
      result = supervisorctl('start')
      if !result.match(/#{new_resource.name}: started$/)
        raise "Supervisor service #{new_resource.name} was unable to be started: #{result}"
      end
    end
  end
end

action :stop do
  create_config_file
  case current_resource.state
  when 'STOPPED'
    Chef::Log.debug "#{ new_resource } is already stopped."
  when 'STOPPING'
    Chef::Log.debug "#{ new_resource } is already stopping."
  when 'BACKOFF'
    Chef::Log.debug "#{ new_resource } is in the BACKOFF state, doesn't need stopping."
  when 'EXITED'
    Chef::Log.debug "#{ new_resource } is in the EXITED state.  Does not need stopping."
  when 'FATAL'
    Chef::Log.debug "#{ new_resource } is in the FATAL state.  Does not need stopping."
  else
    converge_by("Stopping #{ new_resource }") do
      result = supervisorctl('stop')
      if !result.match(/#{new_resource.name}: stopped$/)
        raise "Supervisor service #{new_resource.name} was unable to be stopped: #{result}"
      end
    end
  end
end

action :restart do
  create_config_file
    converge_by("Restarting #{ new_resource }") do
    result = supervisorctl('restart')
    if !result.match(/^#{new_resource.name}: started$/)
      raise "Supervisor service #{new_resource.name} was unable to be started: #{result}"
    end
  end
end

def enable_service
  new_resource.enabled = true
  create_config_file
end

def disable_service
  new_resource.enabled = false
  create_config_file
end

def supervisorctl(action)
  cmd = "supervisorctl #{action} #{cmd_line_args}"
  result = Mixlib::ShellOut.new(cmd).run_command
  result.stdout.rstrip
end

def cmd_line_args
  name = new_resource.service_name
  if new_resource.numprocs > 1
    name += ':*'
  end
  name
end

def create_config_file  
  t = template "#{node['supervisor']['dir']}/#{new_resource.service_name}.#{node[:supervisor][:conf][:extension]}" do
    action :create
    source "program.conf.erb"
    cookbook "supervisor"
    owner "root"
    group "root"
    mode "644"
    variables :prog => new_resource
  end
  
  e = execute "supervisorctl update" do
    action :nothing
    user "root"
  end
  
  t.run_action(:create)
  if t.updated?
    e.run_action(:run)
  end
end

def get_current_state(service_name)
  cmd = "supervisorctl status #{service_name}"
  result = Mixlib::ShellOut.new(cmd).run_command
  stdout = result.stdout
  if stdout.include? "No such process #{service_name}"
    "UNAVAILABLE"
  else
    match = stdout.match("(^#{service_name}\\s*)([A-Z]+)(.+)")
    if match.nil?
      raise "The supervisor service is not running as expected. " \
              "The command '#{cmd}' output:\n----\n#{stdout}\n----"
    end
    match[2]
  end
end

def isEnabled(serviceName)
  configFile = "#{node['supervisor']['dir']}/#{new_resource.service_name}.#{node[:supervisor][:conf][:extension]}"
  exists = ::File.exists?(configFile)
  enabled = exists
  if exists
    result = Mixlib::ShellOut.new("grep autostart #{configFile}").run_command
    enabled = false unless result.stdout.match(/\w*autostart.*false/).nil?
  end
  enabled
end

def load_current_resource
  @current_resource = Chef::Resource::SupervisorService.new(@new_resource.name)
  @current_resource.state = get_current_state(@new_resource.name)
  @current_resource.enabled = isEnabled(@new_resource.name)
end
