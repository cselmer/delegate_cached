class Shelter < ApplicationRecord
  has_many :gear_items, as: :item
end
