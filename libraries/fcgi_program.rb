#
# Author:: Mal Graty <mal.graty@googlemail.com>
# Cookbook Name:: supervisor
# Library:: fcgi_program
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

require_relative 'program'

class Chef
  class Resource::SupervisorFcgiProgram < Resource::SupervisorProgram
    # http://supervisord.org/configuration.html#fcgi-program-x-section-values
    option :socket, true, :kind_of => String
    option :socket_owner, :kind_of => String
    option :socket_mode # see definition

    def initialize(*args)
      super
      @type = 'fcgi-program'
    end

    # support octal socket_mode
    def socket_mode(arg = nil)
      arg = arg.to_s(8) if arg.is_a? Integer
      set_or_return(
        :socket_mode,
        arg,
        :kind_of => [Integer, String],
        :callbacks => {
          'not in valid numeric range' =>
            ->(m) { Integer(m).between?(0, 07777) }
        }
      )
    end
  end
end
