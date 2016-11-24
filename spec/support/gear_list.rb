require File.expand_path('../thru_hike.rb', __FILE__)
require File.expand_path('../hiker.rb', __FILE__)
class GearList < ApplicationRecord
  belongs_to :hiker
  belongs_to :thru_hike
  has_many :gear_items
end
