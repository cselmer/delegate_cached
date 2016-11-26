ActiveRecord::Schema.define do
  create_table :thru_hikes do |t|
    t.integer :hiker_id
    t.integer :trail_id
    t.string :hiker_name
    t.integer :distance
    t.string :gear_list_name
  end

  create_table :hikers do |t|
    t.string :name
    t.string :gear_list_name
  end

  create_table :trails do |t|
    t.string :name
    t.integer :distance
  end

  create_table :gear_lists do |t|
    t.integer :hiker_id
    t.integer :thru_hike_id
    t.string :name
    t.string :hiker_name
  end

  create_table :gear_items do |t|
    t.integer :gear_list_id
    t.string :item_type
    t.integer :item_id
    t.string :item_name
  end

  create_table :shelters do |t|
    t.string :name
  end

  create_table :packs do |t|
    t.string :name
  end
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
class GearItem < ApplicationRecord
  belongs_to :gear_list
  belongs_to :item, polymorphic: true
end
class GearList < ApplicationRecord
  belongs_to :hiker
  belongs_to :thru_hike
end
class Hiker < ApplicationRecord
  has_many :thru_hikes, inverse_of: :hiker
  has_one :gear_list, inverse_of: :hiker
end
class Pack < ApplicationRecord
  has_many :gear_items, as: :item
end
class Shelter < ApplicationRecord
  has_many :gear_items, as: :item
end
class ThruHike < ApplicationRecord
  belongs_to :hiker, inverse_of: :thru_hikes
  belongs_to :trail, inverse_of: :thru_hikes
  has_one :gear_list, inverse_of: :thru_hike
end
class Trail < ApplicationRecord
  has_many :thru_hikes, inverse_of: :trail
end
