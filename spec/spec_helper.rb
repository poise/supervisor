require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/cacher'

at_exit { ChefSpec::Coverage.report! }
