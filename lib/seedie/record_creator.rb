module Seedie
  class RecordCreator
    def initialize(model)
      @model = model
    end
    
    def create!(field_values_set)
      @model.create!(field_values_set)
    end

    def create(field_values_set)
      @model.create(field_values_set)
    end

    def get_random_id
      id = @model.pluck(:id).sample
      raise InvalidAssociationConfigError, "#{@model} does not exist" if id.nil?

      return id
    end
  end
end