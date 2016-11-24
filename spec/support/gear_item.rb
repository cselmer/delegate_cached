require File.expand_path('../gear_list.rb', __FILE__)
require File.expand_path('../shelter.rb', __FILE__)
require File.expand_path('../pack.rb', __FILE__)
class GearItem < ApplicationRecord
  belongs_to :gear_list
  belongs_to :item, polymorphic: true

  delegate_cached :name, to: :item, prefix: true
end
