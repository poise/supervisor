supervisor Cookbook
===================

Installs (Python) supervisor and provides resources to configure programs


Requirements
------------

### Platforms

Supports Debian and RHEL based systems. Tested on:

  - CentOS 6.5
  - Ubuntu 12.04

### Cookbooks

- python


Attributes
----------

- `node.supervisor.inet_port` - The port on which you want to serve the internal web-based admin dashboard, e.g. `'localhost:9001'`
- `node.supervisor.inet_username` - The username for authentication to this HTTP server
- `node.supervisor.inet_password` - The password for authentication to this HTTP server (supports both cleartext and SHA-1 hashed passwords prefixed by `{SHA}`)
- `node.supervisor.dir` - location of supervisor config files
- `node.supervisor.log_dir` - location of supervisor logs
- `node.supervisor.logfile_maxbytes` - max bytes for the supervisord logfile before it is rotated rotated, default `'50MB'`
- `node.supervisor.logfile_backups` - the number of backups of that logfile to keep, default `10`
- `node.supervisor.loglevel` - the minimum severity for those log messages, default `'info'`
- `node.supervisor.minfds` - The minimum number of file descriptors that must be available before supervisord will start successfully.
- `node.supervisor.minprocs` - The minimum number of process descriptors that must be available before supervisord will start successfully.
- `node.supervisor.version` - Sets the version of supervisor to install, must be 3.0+ to use minprocs and minfds.


Resources/Providers
-------------------

### supervisor\_program

#### Actions

The default action is the array `[:enable, :start]`. Actions use the `supervisorctl` application.

- :enable - adds the program to supervisor
- :disable - removes the program from supervisor
- :start - starts the program
- :stop - stops the program
- :restart - restarts the program

#### Attribute Parameters

- `:program_name` - (*Name Attribute*), a string, name of the program

See [the supervisor documentation](http://supervisord.org/configuration.html#program-x-section-values) for a list of possible settings together with information about each, including applicable defaults.

#### Example

```ruby
supervisor_program 'cat' do
  command '/bin/cat'
  directory '/tmp'
  umask 0022
  priority 100
  autostart false
  autorestart true
  exitcodes [0]
  stopsignal :QUIT
  user 'chrism'
  environment 'A' => 'foo', 'B' => 'bar'
end
```

### supervisor\_fcgi\_program

Same as `supervisor_program` but with additional attributes for [fcgi-programs](http://supervisord.org/configuration.html#fcgi-program-x-section-values).

### supervisor\_eventlistener

Same as `supervisor_program` but with additional attributes for [eventlisteners](http://supervisord.org/configuration.html#eventlistener-x-section-values).

### supervisor\_group

- `:group_name` - (*Name Attribute*), a string, name of the group

Uses the same actions as `supervisor_program`, but only supports [group attributes](http://supervisord.org/configuration.html#group-x-section-values).

### Other

Two legacy resources are included for backwards compatability; 

  - `supervisor_service`, superseeded by `supervisor_program` and `supervisor_eventlistener`, and
  - `supervisor_fcgi`, superseeded by `supervisor_fcgi_program`

These resources are **deprecated** and provided solely for compatabily with the current API. They will be removed in a future release.


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
- Author:: Mal Graty <mal.graty@googlemail.com>

```text
Copyright:: 2011-2012, Opscode, Inc <legal@opscode.com>
Copyright:: 2011, Formspring.me
Copyright:: 2014, idio Ltd

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
