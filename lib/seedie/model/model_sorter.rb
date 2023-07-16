module Seedie
  module Model
    class ModelSorter
      def initialize(models)
        @models = models
        @model_dependencies = models.map {|m| [m, get_model_dependencies(m)]}.to_h
        @resolved_queue = []
        @unresolved = []
      end
    
      def sort_by_dependency
        @models.each do |model|
          resolve_dependencies(model) unless @resolved_queue.include?(model)
        end

        @resolved_queue
      end
    
      private
    
      def resolve_dependencies(model)
        if @unresolved.include?(model)
          puts "Circular dependency detected for #{model}. Ignoring..."
          return
        end
    
        @unresolved << model
        dependencies = @model_dependencies[model]
        
        if dependencies
          dependencies.each do |dependency|
            resolve_dependencies(dependency) unless @resolved_queue.include?(dependency)
          end
        end

        @resolved_queue.unshift(model)
        @unresolved.delete(model)
      end
    
      def get_model_dependencies(model)
        associations = model.reflect_on_all_associations(:belongs_to).reject! do |association|
          association.options[:polymorphic] == true || # Excluded Polymorphic Associations
          association.options[:optional] == true # Excluded Optional Associations
        end

        return [] if associations.blank?

        associations.map do |association|
          if association.options[:class_name]
            association.active_record
          else
            association.klass
          end
        end
      end
    end    
  end
end