class ThruHike < ApplicationRecord
  delegate_cached :name, to: :hiker, prefix: true
  delegate_cached :distance, to: :trail, prefix: false, update_when_nil: true
end
