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
    end
  end
end
