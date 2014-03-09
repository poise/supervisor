require 'spec_helper'

describe 'supervisor::default' do
  cached(:version) { '3.0.0' }
  cached(:dir) { '/config/dir' }
  cached(:conffile) { '/config/file' }
  cached(:log_dir) { '/log/dir' }

  context 'on ubuntu' do
    cached(:chef_run) do
      ChefSpec::Runner.new(:platform => 'ubuntu', :version => 12.04) do |node|
        node.set.supervisor.version = version
        node.set.supervisor.dir = dir
        node.set.supervisor.conffile = conffile
        node.set.supervisor.log_dir = log_dir
      end.converge(described_recipe)
    end

    it 'calls the python recipe' do
      expect(chef_run).to include_recipe('python::default')
    end

    it 'does not install python expat' do
      expect do
        chef_run.resource_collection.lookup('package[py27-expat]')
      end.to raise_error(Chef::Exceptions::ResourceNotFound)
    end

    it 'installs supervisor' do
      expect(chef_run).to upgrade_python_pip('supervisor')
        .with_version(version)
    end

    it 'creates config directory' do
      expect(chef_run).to create_directory(dir)
    end

    it 'creates a global config file' do
      expect(chef_run).to create_template(conffile)
        .with_source('supervisord.conf.erb')
    end

    it 'creates a log directory' do
      expect(chef_run).to create_directory(log_dir)
        .with_recursive(true)
    end

    it 'creates a daemon defaults file' do
      expect(chef_run).to create_template('/etc/default/supervisor')
        .with_source('debian/supervisor.default.erb')
    end

    it 'creates an init.d script' do
      expect(chef_run).to create_template('/etc/init.d/supervisor')
        .with_source('debian/supervisor.init.erb')
    end

    it 'enables and starts supervisor as a service' do
      expect(chef_run).to enable_service('supervisor')
        .with_supports(:restart => true, :status => true)
      expect(chef_run).to start_service('supervisor')
    end
  end

  context 'on fedora' do
    cached(:chef_run) do
      ChefSpec::Runner.new(:platform => 'fedora', :version => 20) do |node|
        node.set.supervisor.version = version
        node.set.supervisor.dir = dir
        node.set.supervisor.conffile = conffile
        node.set.supervisor.log_dir = log_dir
      end.converge(described_recipe)
    end

    it 'does not create a daemon defaults file or resource' do
      expect do
        chef_run.resource_collection.lookup 'template[/etc/default/supervisor]'
      end.to raise_error(Chef::Exceptions::ResourceNotFound)
    end

    it 'creates an init.d script' do
      expect(chef_run).to create_template('/etc/init.d/supervisor')
        .with_source('rhel/supervisor.init.erb')
    end
  end

  context 'on smartos' do
    cached(:chef_run) do
      ChefSpec::Runner.new(:platform => 'smartos', :version => 5.11) do |node|
        node.set.supervisor.version = version
        node.set.supervisor.dir = dir
        node.set.supervisor.conffile = conffile
        node.set.supervisor.log_dir = log_dir
      end.converge(described_recipe)
    end

    it 'installs python expat' do
      expect(chef_run).to install_package('py27-expat')
    end

    it 'creates a manifest directory' do
      expect(chef_run).to create_directory('/opt/local/share/smf/supervisord')
    end

    it 'creates and import manifest file' do
      manifest = '/opt/local/share/smf/supervisord/manifest.xml'
      expect(chef_run).to create_template(manifest)
      expect(chef_run).to_not run_execute('svccfg-import-supervisord')
        .with_command("svccfg import #{manifest}")
      resource = chef_run.execute('svccfg-import-supervisord')
      expect(resource).to subscribe_to("template[#{manifest}]")
        .on(:run).immediately
    end

    it 'enables supervisord' do
      expect(chef_run).to enable_service('supervisord')
    end
  end
end
