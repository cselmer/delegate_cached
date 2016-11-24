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
