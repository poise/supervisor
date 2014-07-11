#
# Cookbook Name:: supervisor
# Recipe:: default
#
# Copyright 2011, Opscode, Inc.
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

include_recipe 'python'

package 'py27-expat' do
  action :install
end if platform_family?('smartos')

python_pip 'supervisor' do
  action :upgrade
  version node.supervisor.version if node.supervisor.version
end

directory node.supervisor.dir

template node.supervisor.conffile do
  source 'supervisord.conf.erb'
  variables(
    :inet_port => node.supervisor.inet_port,
    :inet_username => node.supervisor.inet_username,
    :inet_password => node.supervisor.inet_password,
    :supervisord_minfds => node.supervisor.minfds,
    :supervisord_minprocs => node.supervisor.minprocs,
    :supervisor_version => node.supervisor.version
  )
end

directory node.supervisor.log_dir do
  recursive true
end

template '/etc/default/supervisor' do
  source 'debian/supervisor.default.erb'
end if platform_family?('debian')

init_template_dir = value_for_platform_family(
  %w(rhel fedora) => 'rhel',
  'debian' => 'debian'
)

case node.platform
when 'amazon', 'centos', 'debian', 'fedora', 'redhat', 'ubuntu'
  template '/etc/init.d/supervisor' do
    source "#{init_template_dir}/supervisor.init.erb"
    mode 00755
    variables(
      # TODO: use this variable in the debian platform-family template
      # instead of altering the PATH and calling "which supervisord".
      :supervisord => "#{node.python.prefix_dir}/bin/supervisord"
    )
  end

  service 'supervisor' do
    supports :status => true, :restart => true
    action [:enable, :start]
  end
when 'smartos'
  directory '/opt/local/share/smf/supervisord'

  manifest = '/opt/local/share/smf/supervisord/manifest.xml'
  template manifest do
    source 'manifest.xml.erb'
  end

  execute 'svccfg-import-supervisord' do
    command "svccfg import #{manifest}"
    subscribes :run, "template[#{manifest}]", :immediately
    action :nothing
  end

  service 'supervisord' do
    action :enable
  end
end
