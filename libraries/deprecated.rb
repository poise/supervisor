#
# Author:: Mal Graty <mal.graty@googlemail.com>
# Cookbook Name:: supervisor
# Library:: deprecated
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

require_relative 'eventlistener'
require_relative 'fcgi_program'

class Chef
  class Resource::SupervisorFcgi < Resource::SupervisorFcgiProgram; end
  class Resource::SupervisorService < Resource::SupervisorEventlistener
    alias_method :service_name, :program_name
    alias_method :eventlistener_buffer_size, :buffer_size
    alias_method :eventlistener_events, :events_

    require_for_enable.delete(:events)

    def initialize(*args)
      super
      @type = 'program'
    end

    def eventlistener(arg = nil)
      @type = 'eventlistener' if arg.is_a? TrueClass
      set_or_return(
        :eventlistener,
        arg,
        :kind_of => [TrueClass, FalseClass]
      )
    end
  end
end
