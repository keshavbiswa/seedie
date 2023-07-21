module Seedie
  module Model
    class IdGenerator
      def initialize(model)
        @model = model
      end
  
      def random_id
        id = @model.pluck(:id).sample
        raise InvalidAssociationConfigError, "#{@model} has no records" unless id

        return id
      end
      
      def unique_id_for(association_klass)
        model_id_column = "#{@model.to_s.underscore}_id"
      
        unless association_klass.column_names.include?(model_id_column)
          raise InvalidAssociationConfigError, "#{model_id_column} does not exist in #{association_klass}" 
        end
      
        unique_ids = @model.ids - association_klass.pluck(model_id_column)
      
        if unique_ids.empty?
          raise InvalidAssociationConfigError, "No unique ids for #{@model}"
        end
      
        unique_ids.first
      end
    end
  end
end