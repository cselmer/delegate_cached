# frozen_string_literal: true
require 'active_support'
require 'active_record'
require 'delegate_cached/cached_attribute'
require 'delegate_cached/version'

module DelegateCached
  extend ActiveSupport::Concern

  module ClassMethods
    def delegate_cached(attribute, options = {})
      raise ArgumentError, 'The :to option is required' unless options[:to]

      reflection = reflect_on_association(options[:to])

      if reflection.blank?
        raise ArgumentError,
              "The :to association :#{options[:to]} must exist on #{self}"
      end

      CachedAttribute.new(self, attribute, reflection, options).install!
    end
  end
end

ActiveRecord::Base.send :include, DelegateCached
