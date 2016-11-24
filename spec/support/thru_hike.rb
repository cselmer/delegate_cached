require File.expand_path('../hiker.rb', __FILE__)
require File.expand_path('../trail.rb', __FILE__)
require File.expand_path('../gear_list.rb', __FILE__)
class ThruHike < ApplicationRecord
  belongs_to :hiker, inverse_of: :thru_hikes
  belongs_to :trail, inverse_of: :thru_hikes
  has_one :gear_list, inverse_of: :thru_hike

  delegate_cached :name, to: :hiker, prefix: true
  delegate_cached :distance, to: :trail, prefix: false, update_when_nil: true
end
