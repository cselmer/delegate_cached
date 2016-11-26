# DelegateCached

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

First, add a column to the delegating ActiveRecord modelto cache the delegated
value. If using the `prefix: true` options, be sure to use the
`to` prefix in the column name. For example, as below, the column names required would be
`hiker_name` for the first `delegate_cached` definition, and `name` for the
second.

Second, add your `delegate_cached` definition. Note - you may only use
`delegate_cached` on `belongs_to` and `has_one` associations.

```ruby
class ThruHike < ApplicationRecord
  belongs_to :hiker, inverse_of: :thru_hikes
  belongs_to :trail, inverse_of: :thru_hikes

  delegate_cached :name, to: :hiker, prefix: true # hiker_name column required on thru_hikes table
  delegate_cached :name, to: :trail # name column required on thru_hikes tables
end
```

Third, use your models as you typically would with `delegate` When an instance
of the delegated-to model is saved, a callback will update your delegate_cached
value.

## Options

`update_when_nil: true` False by default. When set to true and the referenced
attribute is called, if the existing cached value is nil, it will attempt to
update the attribute value with the delegated value.

`skip_callback: true` False by default. When set to true, the `after_save`
callback on the delegated-to model will not set.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cselmer/delegate_cached. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

Copyright (c) 2016 Chris Selmer. The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
