class GearItem < ApplicationRecord
  delegate_cached :name, to: :item, prefix: true
end
