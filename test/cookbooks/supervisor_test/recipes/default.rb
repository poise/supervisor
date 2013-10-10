#
# Cookbook Name:: supervisor_test
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'supervisor'

supervisor_service 'some_service' do
    command '/bin/cat'
end
