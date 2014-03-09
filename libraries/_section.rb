#
# Author:: Mal Graty <mal.graty@googlemail.com>
# Cookbook Name:: supervisor
# Library:: section
#
# Copyright:: 2014, idio Ltd
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

class Chef
  class Resource::SupervisorSection < Resource::LWRPBase
    # this is, in effect, an abstract resource and should never be
    # created via the default constructor
    private_class_method :new

    actions :enable, :disable, :start, :stop, :restart
    default_action [:enable, :start]

    attribute :section_name, :kind_of => String, :name_attribute => true

    # helper method for registering supervisor options
    def self.option(attr_name, *args)
      # attributes with a trailing underscore are a workaround for
      # conflicting method names in a resource, so map them against the
      # real name by trimming the underscore
      real_attr_name = attr_name.to_s.sub(/_$/, '').to_sym
      options.store(real_attr_name, attr_name)
      if args[0].is_a? TrueClass
        require_for_enable.store(real_attr_name, attr_name)
        args.shift # LWRPBase won't want this
      end
      # hand off arguments to LWRPBase to build the attribute
      attribute(attr_name, *args)
    end

    # hash containing all registered supervisor options
    def self.options
      @options ||= {}
    end

    # hash containing all supervisor options required for the enable action
    def self.require_for_enable
      @require_for_enable ||= {}
    end

    # unlock subclass constructors and give them their own copies of
    # a few class variables so they can modify them in their own scope
    def self.inherited(sub)
      sub.public_class_method :new
      sub.instance_variable_set :@default_action, default_action.dup
      sub.instance_variable_set :@options, options.dup
      sub.instance_variable_set :@require_for_enable, require_for_enable.dup
      sub.instance_variable_set :@resource_name, snake_case_basename(sub.to_s)
      sub.instance_variable_set :@valid_actions, valid_actions.dup
    end

    # section state in supervisorctl (populated by provider)
    attr_accessor :state

    # section type (set in subclasses)
    attr_reader :type

    # one provider to rule them all
    def initialize(*args)
      super
      @provider = Chef::Provider::SupervisorSection
    end

    # get hash of populated registered supervisor options
    def options
      self.class.options.reduce({}) do |options, option|
        option, method = option
        value = send(method)
        value.nil? ? options : options.merge(option => value)
      end
    end
  end
end

class Chef
  class Provider::SupervisorSection < Provider # rubocop:disable ClassLength
    include Chef::Mixin::ShellOut

    # http://supervisord.org/subprocess.html#process-states
#     BACKOFF = 'BACKOFF' unless defined?(BACKOFF)
    EXITED = 'EXITED' unless defined?(EXITED)
    FATAL = 'FATAL' unless defined?(FATAL)
    MISSING = 'MISSING' unless defined?(MISSING) # internal
    RUNNING = 'RUNNING' unless defined?(RUNNING)
#     STARTING = 'STARTING' unless defined?(STARTING)
    STOPPED = 'STOPPED' unless defined?(STOPPED)
#     STOPPING = 'STOPPING' unless defined?(STOPPING)
    UNKNOWN = 'UNKNOWN' unless defined?(UNKNOWN)

    STABLE = [EXITED, FATAL, RUNNING, STOPPED] unless defined?(STABLE)

    def define_resource_requirements
      define_resource_requirements_for_enable
      requirements.assert(:start, :stop, :restart) do |a|
        a.assertion do
          current_resource.state != MISSING &&
          current_resource.state != UNKNOWN
        end
        a.failure_message(RuntimeError, "#{new_resource} does not exist")
        a.whyrun("Assuming #{new_resource} would have been created")
      end
    end

    def define_resource_requirements_for_enable
      new_resource.class.require_for_enable.each do |name, attr|
        requirements.assert(:enable) do |a|
          a.assertion { new_resource.send attr }
          a.failure_message Chef::Exceptions::ValidationFailed,
                            "Required argument #{name} is missing!"
        end
      end
    end

    def load_current_resource
      @current_resource = new_resource.class.new(new_resource.section_name)
      current_state
    end

    def whyrun_supported?
      true
    end

    def action_enable
      message = ::File.exists?(path) ? 'updated' : 'enabled'
      config_file.run_action :create
      reload(message) if config_file.updated_by_last_action?
    end

    def action_disable
      config_file.run_action :delete
      reload('disabled') if config_file.updated_by_last_action?
    end

    def action_start
      wait_til_stable # we can only act on stable states, see supervisor docs
      case current_resource.state
      when RUNNING
        Chef::Log.debug "#{new_resource} is already started"
      when EXITED, FATAL, STOPPED
        converge_by "start #{new_resource}" do
          supervisor('start') || fail("#{new_resource} could not start")
          Chef::Log.info("#{new_resource} started")
        end
      end
    end

    def action_stop
      wait_til_stable
      case current_resource.state
      when EXITED, FATAL, STOPPED
        Chef::Log.debug "#{new_resource} is already stopped"
      when RUNNING
        converge_by "stop #{new_resource}" do
          supervisor('stop') || fail("#{new_resource} could not be stopped")
          Chef::Log.info("#{new_resource} stopped")
        end
      end
    end

    def action_restart
      wait_til_stable
      converge_by "restart #{new_resource}" do
        supervisor('restart') || fail("#{new_resource} could not be restarted")
        Chef::Log.info("#{new_resource} restarted")
      end
    end

    def config_file
      @config_file ||= begin
        template = Chef::Resource::Template.new path, run_context
        template.cookbook 'supervisor'
        template.source 'section.conf.erb'
        template.variables :name => new_resource.section_name,
                           :opts => new_resource.options,
                           :type => new_resource.type
        template
      end
    end

    def current_state
      name = Regexp.escape(new_resource.section_name)
      result = shell_out!('supervisorctl status')
        .stdout
        .match("^#{name}(?:\\:\\S+)?\\s+([A-Z]+)\\b")
      current_resource.state = result.nil? ? MISSING : Regexp.last_match[1]
    end

    def identifier
      # groups and any program with a name other than the default
      # ('%(program_name)s') need the group wildcard (':*') appended in
      # order to be recognised
      @identifier ||= new_resource.section_name +
        if new_resource.type == 'group' ||
          new_resource.process_name.nil? ||
          new_resource.process_name  == '%(program_name)s'
          ':*'
        end
    end

    def path
      "#{node.supervisor.dir}/#{new_resource.section_name}.conf"
    end

    def reload(message)
      converge_by 'reload supervisor configuration' do
        shell_out! 'supervisorctl update'
        Chef::Log.info("#{new_resource} #{message}")
      end
    end

    def stable
      @stable_states ||=
        if STABLE.empty? || STABLE.size == 1
          STABLE.to_s
        else
          [STABLE[0...-1].join(', '), STABLE.last].join(' or ')
        end
    end

    def supervisor(command)
      # only check the last line for 'ERROR' (to determine success)
      # because restart will issue one on the penultimate line if an
      # attempt is made to restart a process that is not running
      shell_out!("supervisorctl #{command} #{identifier}")
        .stdout.lines.to_a.last
        .match(/ERROR/).nil?
    end

    def wait_til_stable(max_tries = 20)
      return if whyrun_mode? # assume process would be in stable state
      max_tries.times do
        return if STABLE.include? current_state
        Chef::Log.debug("waiting for #{new_resource} to be in state #{stable}")
        sleep 1
      end
      fail "#{new_resource} not in state #{stable} after #{max_tries} tries"
    end
  end
end
