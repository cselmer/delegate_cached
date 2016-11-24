module DelegateCached
  class ModelData
    attr_reader :model, :column, :association, :reflection

    def initialize(model, column, association, reflection)
      @model = model
      @column = column
      @association = association
      @reflection = reflection
    end

    def plural_underscored_model_name
      model.to_s.pluralize.underscore
    end

    def underscored_model_name
      model.to_s.underscore
    end
  end
end
