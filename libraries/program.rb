#
# Author:: Mal Graty <mal.graty@googlemail.com>
# Cookbook Name:: supervisor
# Library:: program
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

require_relative '_section'

class Chef
  class Resource::SupervisorProgram < Resource::SupervisorSection
    # localise name attribute
    alias_method :program_name, :section_name

    # http://supervisord.org/configuration.html#program-x-section-values
    option :command, true, :kind_of => String
    option :process_name, :kind_of => String
    option :numprocs, :kind_of => Integer
    option :numprocs_start, :kind_of => Integer
    option :priority, :kind_of => Integer
    option :autostart, :kind_of => [TrueClass, FalseClass]
    option :autorestart, :kind_of => [String, Symbol, TrueClass, FalseClass]
    option :startsecs, :kind_of => Integer
    option :startretries, :kind_of => Integer
    option :exitcodes, :kind_of => Array, :cannot_be => :empty
    option :stopsignal, :kind_of => [String, Symbol]
    option :stopwaitsecs, :kind_of => Integer
    option :stopasgroup, :kind_of => [TrueClass, FalseClass]
    option :killasgroup, :kind_of => [TrueClass, FalseClass]
    option :user, :kind_of => String
    option :redirect_stderr, :kind_of => [TrueClass, FalseClass]
    option :stdout_logfile, :kind_of => String
    option :stdout_logfile_maxbytes, :kind_of => String
    option :stdout_logfile_backups, :kind_of => Integer
    option :stdout_capture_maxbytes, :kind_of => String
    option :stdout_events_enabled, :kind_of => [TrueClass, FalseClass]
    option :stdout_syslog, :kind_of => [TrueClass, FalseClass]
    option :stderr_logfile, :kind_of => String
    option :stderr_logfile_maxbytes, :kind_of => String
    option :stderr_logfile_backups, :kind_of => Integer
    option :stderr_capture_maxbytes, :kind_of => String
    option :stderr_events_enabled, :kind_of => [TrueClass, FalseClass]
    option :stderr_syslog, :kind_of => [TrueClass, FalseClass]
    option :environment, :kind_of => Hash, :cannot_be => :empty
    option :directory, :kind_of => String
    option :umask # see definition
    option :serverurl, :kind_of => String

    def initialize(*args)
      super
      @type = 'program'
    end

    # support octal umask
    def umask(arg = nil)
      arg = arg.to_s(8) if arg.is_a? Integer
      set_or_return(
        :umask,
        arg,
        :kind_of => [Integer, String],
        :callbacks => {
          'not in valid numeric range' =>
            ->(m) { Integer(m).between?(0, 0777) } # umask; no sticky or setuid
        }
      )
    end
  end
end
