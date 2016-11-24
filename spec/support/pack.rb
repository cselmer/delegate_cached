class Pack < ApplicationRecord
  has_many :gear_items, as: :item
end
