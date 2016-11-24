require File.expand_path('../thru_hike.rb', __FILE__)
class Trail < ApplicationRecord
  has_many :thru_hikes, inverse_of: :trail
end
