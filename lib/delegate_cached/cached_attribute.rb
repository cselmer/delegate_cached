# frozen_string_literal: true
require 'delegate_cached/model_data'
require 'delegate_cached/installer'
require 'delegate_cached/source_installer'
require 'delegate_cached/target_installer'
module DelegateCached
  class CachedAttribute
    attr_reader :source, :target, :options

    def initialize(model, attribute, reflection, options)
      @options = options
      @source = source_model_data(model, attribute, reflection, options)

      inverse = nil
      if reflection.polymorphic?
        @options[:polymorphic] = true
      else
        inverse = reflection.inverse_of
        inverse ||= retrieve_reflection(options[:inverse_of])
        @options[:skip_callback] = true if inverse.nil?
      end

      @target = target_model_data(attribute, reflection, inverse)

      @source_installer = SourceInstaller.new(@source, @target, options)
      @target_installer = TargetInstaller.new(@source, @target, options)
    end

    def install!
      validate
      @source_installer.install_instance_methods
      @target_installer.install_instance_methods
    end

    protected

    def source_model_data(model, attribute, reflection, options)
      ModelData.new(model,
                    source_column_name(attribute, options),
                    options[:to],
                    reflection)
    end

    def target_model_data(attribute, reflection, inverse)
      ModelData.new(reflection.class_name.safe_constantize,
                    attribute,
                    @options[:polymorphic] ? '' : inverse.name,
                    inverse)
    end

    def retrieve_reflection(inverse_of)
      @source.reflection.klass.reflect_on_association(inverse_of)
    end

    def validate
      validate_column_exists(@source.model, @source.column)
      return if @options[:polymorphic]
      validate_column_exists(@target.model, @target.column)
      validate_target_association
    end

    def validate_column_exists(model, column)
      # The models cannot be validated if they are preloaded and the
      # attribute/column is not in the database (the migration has not been run)
      # or tables do not exist. This usually occurs in the 'test' and
      # 'production' environment or during migrations.
      return if defined?(Rails) && Rails.configuration.cache_classes ||
                !model.table_exists? || !model.table_exists?

      return if model.columns.detect { |cl| cl.name == column.to_s }
      missing_attribute(model, column)
    end

    def validate_inverse(inverse)
      return unless inverse.blank?
      raise ArgumentError,
            "#{@source.association} association on #{@source} " \
            'must either have an :inverse_of or you may pass :inverse_of into' \
            ' delegate_cached.'
    end

    def validate_target_association
      return if @target.model.instance_methods.include?(@target.association)
      raise ArgumentError,
            "The #{@target.association} association does not exist on " \
            "#{@target.model}"
    end

    def missing_attribute(model, attribute)
      message = "WARNING: `#{attribute}' is not an attribute of `#{model}'." \
                'This may happen before or during migrations when your column' \
                'has not yet been created.'

      if defined?(Rails)
        Rails.logger.warn message
      else
        STDERR.puts message
      end
    end

    def source_column_name(attribute, options)
      return attribute.to_s unless options[:prefix]
      "#{options[:to]}_#{attribute}"
    end
  end
end
