# DelegateCached

# This is not really a very useful header

[![Gem Version](https://badge.fury.io/rb/delegate_cached.svg)](https://badge.fury.io/rb/delegate_cached)
[![Build Status](https://travis-ci.org/cselmer/delegate_cached.svg?branch=master)](https://travis-ci.org/cselmer/delegate_cached)
[![Code Climate](https://codeclimate.com/github/cselmer/delegate_cached/badges/gpa.svg)](https://codeclimate.com/github/cselmer/delegate_cached)
[![Test Coverage](https://codeclimate.com/github/cselmer/delegate_cached/badges/coverage.svg)](https://codeclimate.com/github/cselmer/delegate_cached/coverage)

## Overview

`delegate_cached` allows you to cache delegated attributes on the delegating
model and provides options to update the cached values when changed on the
delegated-to model.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'delegate_cached'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install delegate_cached

## Usage

We'll be caching the delegated attribute value, so your delegating ActiveRecord
model will need a column to store the value. The column name will need to match
the delegated attribute, or if using the `prefix: true` option, match the
delegated attribute preceded by the `to:` option and `_`. For example, as below,
the column names required would be `hiker_name` for the first `delegate_cached`
definition, and `name` for the second. Create and run a migration for your new
column/s unless they already exist.

```ruby
class ThruHike < ApplicationRecord
  belongs_to :hiker, inverse_of: :thru_hikes
  belongs_to :trail, inverse_of: :thru_hikes

  delegate_cached :name, to: :hiker, prefix: true # 'hiker_name' column required on thru_hikes table
  delegate_cached :name, to: :trail               # 'name' column required on thru_hikes tables
end
```

Now, add your `delegate_cached` definition as in the example above. Note - you
may only use `delegate_cached` on `belongs_to` and `has_one` associations.

This adds several methods to the delegating and delegated-to models.

```ruby
class ThruHike < ApplicationRecord
  belongs_to :hiker, inverse_of: :thru_hikes
  belongs_to :trail, inverse_of: :thru_hikes

  delegate_cached :name, to: :hiker, prefix: true # 'hiker_name' column required on thru_hikes table
  delegate_cached :name, to: :trail               # 'name' column required on thru_hikes tables

  # This callback added by delegate_cached
  before_save :set_delegate_cached_value_for_hiker_name

  # This method added by delegate_cached
  def set_delegate_cached_value_for_hiker_name
    return unless hiker
    self['hiker_name'] = hiker.name
  end

  # This method added by delegate_cached
  def update_delegate_cached_value_for_hiker_name
    update(hiker_name: hiker.name)
  end

  # This method added by delegate_cached and overrides the ActiveRecord accessor
  # Cached value is returned unless nil. When nil, update the value from the
  # delegated_to model. To disable updating, use the update_when_nil = false option
  def hiker_name
    unless self['hiker_name'].nil?
      return self['hiker_name']
    end
    update_delegate_cached_value_for_hiker_name
    hiker.name
  end
end
```

```ruby
class Hiker < ApplicationRecord
  has_many :thru_hikes, inverse_of: :hiker

  # This callback added by delegate_cached
  # To disable the callback, use the skip_callback = true option
  after_save :update_delegate_cached_value_for_thru_hikes_hiker_name, if: :name_changed?

  # This method added by delegate_cached
  def update_delegate_cached_value_for_thru_hikes_hiker_name
    ThruHike.where(hiker_id: id)
            .update_all(hiker_name: name)
  end
end
```

```ruby
class Trail < ApplicationRecord
  has_many :thru_hikes, inverse_of: :trail

  # This callback added by delegate_cached
  # To disable the callback, use the skip_callback = true option
  after_save :update_delegate_cached_value_for_thru_hikes_name, if: :name_changed?

  # This method added by delegate_cached
  def update_delegate_cached_value_for_thru_hikes_name
    ThruHike.where(hiker_id: id)
            .update_all(name: name)
  end
end
```

Finally, use your models as you typically would with `delegate` When an instance
of the delegated-to model is saved, a callback will update your delegate_cached
value.


## Options

`to: X` Required. Must be a `belongs_to` or `has_one` ActiveRecord association

`prefix: true` False by default. Changes the accessor name from `accessor` to
`to_accessor`

`inverse_of` Tells `delegate_cached` the inverse_of for the `to` association
when it is not defined on the association itself.

`update_when_nil: true` False by default. When set to true and the referenced
attribute is called, if the existing cached value is nil, it will attempt to
update the attribute value with the delegated value.

`skip_callback: true` False by default. When set to true, the `after_save`
callback on the delegated-to model will not set.


## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/cselmer/delegate_cached. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to adhere
to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests.


## License

Copyright (c) 2016 Chris Selmer. The gem is available as open source under the
terms of the [MIT License](http://opensource.org/licenses/MIT).
