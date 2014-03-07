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
