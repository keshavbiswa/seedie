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
        raise "Circular dependency detected: #{model}" if @unresolved.include?(model)
    
        @unresolved << model
        dependencies = @model_dependencies[model]
        puts "I have dependencies: #{dependencies}"
        
        if dependencies
          dependencies.each do |dependency|
            resolve_dependencies(dependency) unless @resolved_queue.include?(dependency)
          end
        end

        @resolved_queue.unshift(model)
        @unresolved.delete(model)
      end
    
      def get_model_dependencies(model)
        puts "Getting dependencies for #{model}"
        associations = model.reflect_on_all_associations(:belongs_to).reject! do |association|
          association.options[:polymorphic] == true || # Excluded Polymorphic Associations
          association.options[:optional] == true # Excluded Optional Associations
        end

        return [] if associations.blank?

        puts "Associations for #{model}: #{associations}"
        
        associations.map do |association|
          if association.options[:class_name]
            association.options[:class_name].constantize
          else
            association.klass
          end
        end
      end
    end    
  end
end