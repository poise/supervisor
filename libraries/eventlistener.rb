#
# Author:: Mal Graty <mal.graty@googlemail.com>
# Cookbook Name:: supervisor
# Library:: eventlistener
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
  class Resource::SupervisorEventlistener < Resource::SupervisorProgram
    # http://supervisord.org/configuration.html#eventlistener-x-section-values
    option :buffer_size, :kind_of => Integer
    option :events_, true, :kind_of => Array, :cannot_be => :empty # conflict
    option :result_handler, :kind_of => String

    def initialize(*args)
      super
      @type = 'eventlistener'
    end

    # work around name conflict with Resource::events
    def events(arg = nil)
      return super() if arg.nil?
      events_(arg)
    end
  end
end
