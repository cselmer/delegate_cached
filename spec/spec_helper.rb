require 'active_record'
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift File.expand_path("support", __FILE__)
require 'delegate_cached'

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

require 'support/setup'
require 'support/application_record'
require 'support/thru_hike'
require 'support/hiker'
require 'support/trail'
require 'support/gear_item'
require 'support/gear_list'

# Load support files
#Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
