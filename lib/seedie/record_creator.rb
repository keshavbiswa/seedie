module Seedie
  class RecordCreator
    include Reporters::Reportable
    
    def initialize(model, reporters = [])
      @model = model
      @reporters = reporters

      add_observers(@reporters)
    end
    
    def create!(field_values_set)
      record = @model.create!(field_values_set)
      notify(:record_created, name: "#{record.class}", id: "#{record.id}")

      record
    end

    def create(field_values_set)
      begin
        create!(field_values_set)
      rescue ActiveRecord::RecordInvalid => e
        notify(:record_invalid, record: e.record)
        return nil
      end
    end

    def get_random_id
      id = @model.pluck(:id).sample
      raise InvalidAssociationConfigError, "#{@model} does not exist" if id.nil?

      return id
    end
  end
end