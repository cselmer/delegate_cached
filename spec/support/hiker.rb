require File.expand_path('../thru_hike.rb', __FILE__)
require File.expand_path('../gear_list.rb', __FILE__)
class Hiker < ApplicationRecord
  has_many :thru_hikes, inverse_of: :hiker
  has_one :gear_list, inverse_of: :hiker

  delegate_cached :name, to: :gear_list, prefix: true
end
