module DelegateCached
  class TargetInstaller < Installer
    def install_instance_methods
      install_update_method
      install_callback unless options[:no_callback] || options[:polymorphic]
    end

    def install_update_method
      @target.model.class_eval %(
        def #{update_method_name}
          #{update_method_body}
        end
      )
    end

    def install_callback
      @target.model.class_eval %(
        after_save :#{update_method_name}, if: :#{@target.column}_changed?
      )
    end

    def update_method_name
      'update_delegate_cached_value_for_' \
        "#{@source.plural_underscored_model_name}_#{@source.column}"
    end

    def update_method_body
      case @source.reflection.macro
      when :belongs_to
        update_method_body_for_has_one_or_has_many
      when :has_one
        update_method_body_for_belongs_to
      end
    end

    def update_all_line
      ".update_all(#{@source.column}: #{@target.column})"
    end

    def update_method_body_for_has_one_or_has_many
      %(
          #{@source.model}.where(#{@source.association}_id: id)
                          #{update_all_line}
      )
    end

    def update_method_body_for_belongs_to
      %(
          #{@source.model}.where(id: #{@target.association}_id)
                          #{update_all_line}
      )
    end
  end
end
