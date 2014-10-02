supervisor Cookbook
===================
Installs (Python) supervisor and provides resources to configure services


Requirements
------------
### Platforms
Supports Debian and RHEL based systems. Tested on Ubuntu 12.04, 10.04, CentOS 6.5.

### Cookbooks
- python


Attributes
----------
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>[:supervisor][:inet_port]</tt></td>
    <td>String</td>
    <td>The port on which you want to serve the internal web-based admin dashboard</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>[:supervisor][:inet_username]</tt></td>
    <td>String</td>
    <td>The username for authentication to this HTTP server</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>[:supervisor][:inet_password]</tt></td>
    <td>String</td>
    <td>The password for authentication to this HTTP server (supports both cleartext and SHA-1 hashed passwords prefixed by `{SHA}`)</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>[:supervisor][:dir]</tt></td>
    <td>String</td>
    <td>location of supervisor config files/td>
    <td>smartos: <tt> '/opt/local/etc/supervisor.d'</tt> others: <tt>'/etc/supervisor.d'</tt></td>
  </tr>
  <tr>
    <td><tt>[:supervisor][:log_dir]</tt></td>
    <td>String</td>
    <td>location of supervisor logs</td>
    <td><tt>'/var/log/supervisor'</tt></td>
  </tr>
  <tr>
    <td><tt>[:supervisor][:logfile_maxbytes]</tt></td>
    <td>String</td>
    <td>max bytes for the supervisord logfile before it is rotated rotated</td>
    <td><tt>'50MB'</tt></td>
  </tr>
  <tr>
    <td><tt>[:supervisor][:logfile_backups]</tt></td>
    <td>Integer</td>
    <td>the number of backups of that logfile to keep</td>
    <td><tt>10</tt></td>
  </tr>
  <tr>
    <td><tt>[:supervisor][:loglevel]</tt></td>
    <td>String</td>
    <td>the minimum severity for those log messages</td>
    <td><tt>'info'</tt></td>
  </tr>
  <tr>
    <td><tt>[:supervisor][:minfds]</tt></td>
    <td>Integer</td>
    <td>The minimum number of file descriptors that must be available before supervisord will start successfully.</td>
    <td><tt>1024</tt></td>
  </tr>
  <tr>
    <td><tt>[:supervisor][:minprocs]</tt></td>
    <td>Integer</td>
    <td>The minimum number of process descriptors that must be available before supervisord will start successfully.</td>
    <td><tt>200</tt></td>
  </tr>
  <tr>
    <td><tt>[:supervisor][:version]</tt></td>
    <td>String</td>
    <td><Sets the version of supervisor to install, must be 3.0+ to use minprocs and minfds./td>
    <td><tt>No default. Latest will be installed if not set.</tt></td>
  </tr>
  <tr>
    <td><tt>[:supervisor][:socket_file]</tt></td>
    <td>String</td>
    <td>location of supervisor socket file.</td>
    <td><tt>'/var/run/supervisor.sock'</tt></td>
  </tr>
</table>


Resources/Providers
-------------------
### supervisor\_service

#### Actions

The default action is the array `[:enable, :start]`. Actions use the `supervisorctl` program.

- :enable - enables the service at boot time
- :disable - disables the service at boot time
- :start - starts the service
- :stop - stops the service
- :restart - restarts the service
- :reload - reloads the service

#### Attribute Parameters

- `:service_name` - (*Name Attribute*), a string, name of the service

The following attributes are used in the program.conf.erb as the values for the corresponding configuration option. See [the supervisor documentation](http://supervisord.org/configuration.html#program-x-section-values) for more information about each setting, including applicable defaults.

- `:command` - string
- `:process_name` - string
- `:numprocs` - integer
- `:numprocs_start` - integer
- `:priority` - integer
- `:autostart` - true or false
- `:autorestart` - string, symbol, true or false
- `:startsecs` - integer
- `:startretries` - integer
- `:exitcodes` - array
- `:stopsignal` - string or symbol
- `:stopwaitsecs` - integer
- `:user` - string or nil
- `:redirect_stderr` - true or false
- `:stdout_logfile` - string
- `:stdout_logfile_maxbytes` - string
- `:stdout_logfile_backups` - string
- `:stdout_capture_maxbytes` - string
- `:stdout_events_enabled` - true or false
- `:stderr_logfile` - string
- `:stderr_logfile_maxbytes` - string
- `:stderr_logfile_backups` - integer
- `:stderr_capture_maxbytes` - string
- `:stderr_events_enabled` - true or false
- `:environment`- hash
- `:directory`- string or nil
- `:umask` - string or nil
- `:serverurl` - string

#### Examples

```ruby
supervisor_service "celery" do
  action :enable
  autostart false
  user "nobody"
end
```


Recipes
-------
### default
Includes the python recipe, installs the supervisor PIP package and sets up supervisor.


License & Authors
-----------------
- Author:: Noah Kantrowitz <noah@opscode.com>
- Author:: Gilles Devaux <gilles.devaux@gmail.com>
- Author:: Sam Clements <sam.clements@datasift.com>
- Author:: Chris Jerdonek <chris.jerdonek@gmail.com>

```text
Copyright:: 2011-2012, Opscode, Inc <legal@opscode.com>
Copyright:: 2011, Formspring.me

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
