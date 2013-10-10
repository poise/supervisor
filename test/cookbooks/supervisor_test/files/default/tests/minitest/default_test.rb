require 'minitest/spec'
require File.expand_path("../support/helpers", __FILE__)


describe_recipe 'supervisor::default' do
  it 'should use a modern version of pip' do
    pip_version = %x(pip -V | cut -d' ' -f2).strip
    pip_version.must_equal('1.4.1')
  end

  it 'should create the some_service configuration file' do
      file('/etc/supervisor.d/some_service.conf').must_exist
  end
end
