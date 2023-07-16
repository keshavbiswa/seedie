module Seedie
  module Model
    class Creator
      include Reporters::Reportable
      
      def initialize(model, reporters = [])
        @model = model
        @reporters = reporters

        add_observers(@reporters)
      end
      
      def create!(field_values_set)
        record = @model.create!(field_values_set)
        report(:record_created, name: "#{record.class}", id: "#{record.id}")

        record
      end

      def create(field_values_set)
        begin
          create!(field_values_set)
        rescue ActiveRecord::RecordInvalid => e
          report(:record_invalid, record: e.record)
          return nil
        end
      end

      def get_random_id
        id = @model.pluck(:id).sample
        raise InvalidAssociationConfigError, "#{@model} does not exist" if id.nil?

        return id
      end
      
      def get_unique_id(association_klass)      
        existing_ids = association_klass.pluck("#{@model.to_s.underscore}_id")
        unique_ids = @model.pluck(:id) - existing_ids

        raise InvalidAssociationConfigError, "#{@model} does not exist" if unique_ids.nil?

        return unique_ids.sample
      end
    end
  end
end