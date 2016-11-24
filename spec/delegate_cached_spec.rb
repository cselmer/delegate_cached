require 'spec_helper'

# rubocop:disable Metrics/LineLength
describe DelegateCached do
  it 'has a version number' do
    expect(DelegateCached::VERSION).not_to be nil
  end

  def expect_model_to_have_instance_method(model, method)
    expect(model.instance_methods).to include(method)
  end

  def expect_model_to_have_callback(model, callback_type, callback)
    expect(model_has_callback?(model, callback_type, callback)).to be true
  end

  def expect_model_to_not_have_callback(model, callback_type, callback)
    expect(model_has_callback?(model, callback_type, callback)).to be false
  end

  def model_has_callback?(model, callback_type, callback)
    model._save_callbacks
         .select { |cb| cb.kind.eql?(callback_type) }
         .collect(&:filter)
         .include?(callback)
  end

  let!(:hiker) { Hiker.create(name: 'Haiku') }
  let!(:trail) { Trail.create(name: 'Appalachian Trail', distance: 2168) }
  let!(:thru_hike) { ThruHike.create( hiker: hiker, trail: trail) }
  let!(:gear_list) { GearList.create( hiker: hiker, thru_hike: thru_hike, name: 'Awesome Gear List') }
  let!(:shelter) { Shelter.create( name: 'Cuben Fiber Tarp') }
  let!(:gear_item) { GearItem.create( gear_list: gear_list, item: shelter) }

  context 'Delegating class' do
    context 'when options[:prefix] = true' do
      it 'has an update method for the cached column' do
        expect_model_to_have_instance_method(ThruHike, :update_delegate_cached_value_for_hiker_name)
      end

      it 'has a setter method for the cached column' do
        expect_model_to_have_instance_method(ThruHike, :set_delegate_cached_value_for_hiker_name)
      end
    end

    context 'when options[:prefix] not set' do
      it 'has an update method for the cached column' do
        expect_model_to_have_instance_method(ThruHike, :update_delegate_cached_value_for_distance)
      end

      it 'has a setter method for the cached column' do
        expect_model_to_have_instance_method(ThruHike, :set_delegate_cached_value_for_distance)
      end
    end

    describe 'delegate cached column' do
      it 'initially has a nil value' do
        expect(thru_hike['hiker_name']).to be_nil
      end

      describe 'accessor method' do
        it 'returns a value' do
          expect(thru_hike.hiker_name).not_to be_nil
        end

        it 'returns the value from the delegated-to association' do
          expect(thru_hike.hiker_name).to eq hiker.name
        end

        context 'when options[:update_when_nil] is not set or false' do
          it 'does not set the column value' do
            thru_hike.hiker_name
            expect(thru_hike['hiker_name']).to be_nil
          end
        end

        context 'when options[:update_when_nil] is true' do
          it 'sets a column value' do
            thru_hike.distance
            expect(thru_hike['distance']).not_to be_nil
          end

          it 'sets the correct column value' do
            thru_hike.distance
            expect(thru_hike['distance']).to eq trail.distance
          end

          it 'does not change the column value if already set' do
            thru_hike.distance = 12
            thru_hike.distance
            expect(thru_hike['distance']).to eq 12
          end
        end

        context 'when options[:to] is a standard :belongs_to association' do
          it 'returns the delegated value' do
            expect(thru_hike.hiker_name).to eq hiker.name
          end
        end

        context 'when options[:to] is a polymorphic :belongs_to association' do
          it 'returns the delegated value' do
            expect(gear_item.item_name).to eq shelter.name
          end
        end

        context 'when options[:to] is a standard :has_one association' do
          it 'returns the delegated value' do
            expect(hiker.gear_list_name).to eq gear_list.name
          end
        end

        xcontext 'when options[:to] is a polymorphic :has_one association' do
          xit 'returns the delegated value' do
          end
        end
      end
    end
  end

  context 'Delegated-to class' do
    context 'when options[:prefix] = true' do
      it 'has an update method for the delegated cached column' do
        expect_model_to_have_instance_method(Hiker, :update_delegate_cached_value_for_thru_hikes_hiker_name)
      end

      it 'has an after-save callback for the update method' do
        expect_model_to_have_callback(Hiker, :after, :update_delegate_cached_value_for_thru_hikes_hiker_name)
      end
    end

    context 'when options[:prefix] is not set' do
      it 'has an update method for the delegated cached column' do
        expect_model_to_have_instance_method(Trail, :update_delegate_cached_value_for_thru_hikes_distance)
      end

      it 'has an after_save callback for the update method' do
        expect_model_to_have_callback(Trail, :after, :update_delegate_cached_value_for_thru_hikes_distance)
      end
    end

    context 'when updating the delegated-to column' do
      context 'when source assocation is :belongs_to' do
        it 'updates the cached value' do
          thru_hike.update(hiker_name: hiker.name)
          hiker.update(name: 'Glacier')
          thru_hike.reload
          expect(thru_hike.hiker_name).to eq 'Glacier'
        end
      end

      context 'when source association is :belongs_to polymorphic' do
        it 'does not update a cached value' do
          original_shelter_name = shelter.name
          gear_item.update(item_name: original_shelter_name)
          shelter.update(name: 'Heavy Coleman Tent')
          gear_item.reload
          expect(gear_item.item_name).to eq original_shelter_name
        end
      end

      context 'when source association is :has_one' do
        it 'updates the cached value' do
          hiker.update(gear_list_name: gear_list.name)
          gear_list.update(name: 'New Gear List Name')
          hiker.reload
          expect(hiker.gear_list_name).to eq 'New Gear List Name'
        end
      end

      xcontext 'when source association is :has_one polymorphic' do
        xit 'updates the cached value' do
        end
      end
    end
  end
end
# rubocop:enable Metrics/LineLength
