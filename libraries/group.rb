#
# Author:: Mal Graty <mal.graty@googlemail.com>
# Cookbook Name:: supervisor
# Library:: group
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
  class Resource::SupervisorGroup < Resource::SupervisorSection
    # localise name attribute
    alias_method :group_name, :section_name

    # http://supervisord.org/configuration.html#group-x-section-values
    option :programs, true, :kind_of => Array, :cannot_be => :empty
    option :priority, :kind_of => Integer

    def initialize(*args)
      super
      @type = 'group'
    end
  end
end
