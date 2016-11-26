class Hiker < ApplicationRecord
  delegate_cached :name, to: :gear_list, prefix: true
end
