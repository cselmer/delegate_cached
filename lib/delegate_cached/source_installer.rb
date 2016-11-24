module DelegateCached
  class SourceInstaller < Installer
    def install_instance_methods
      install_update_method
      install_accessor_override_method
      install_setter_override_method
      install_callback
    end

    def update_method_name
      "update_delegate_cached_value_for_#{@source.column}"
    end

    def set_method_name
      "set_delegate_cached_value_for_#{@source.column}"
    end

    def install_update_method
      @source.model.class_eval %(
        def #{update_method_name}
          update(#{@source.column}: #{@source.association}.#{@target.column})
        end
      )
    end

    def install_accessor_override_method
      @source.model.class_eval %(
        def #{@source.column}
          unless self['#{@source.column}'].nil?
            return self['#{@source.column}']
          end
          #{update_if_update_when_nil_option}
          #{@source.association}.#{@target.column}
        end
      )
    end

    def install_setter_override_method
      @source.model.class_eval %(
        def #{set_method_name}
          return unless #{@source.association}
          self['#{@source.column}'] = #{@source.association}.#{@target.column}
        end
      )
    end

    def install_callback
      @source.model.class_eval %(
        before_save :#{set_method_name}#{callback_if_statement}
      )
    end

    def callback_if_statement
      return nil if @source.reflection.macro == :has_one
      ", if: :#{@source.column}_changed?"
    end

    def update_if_update_when_nil_option
      update_method_name if options[:update_when_nil]
    end
  end
end
