# frozen_string_literal: true

module Seedie
  module Model
    class ModelSorter
      include PolymorphicAssociationHelper

      def initialize(models)
        @models = models
        @model_dependencies = models.index_with { |m| get_model_dependencies(m) }
        @resolved_queue = []
        @unresolved = []
      end

      def sort_by_dependency
        add_independent_models_to_queue

        @models.each do |model|
          resolve_dependencies(model) unless @resolved_queue.include?(model)
        end

        @resolved_queue
      end

      private

        # Independent models need to be added first
        def add_independent_models_to_queue
          @models.each do |model|
            if @model_dependencies[model].empty?
              @resolved_queue << model
            end
          end
        end

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

          @resolved_queue << model
          @unresolved.delete(model)
        end

        def get_model_dependencies(model)
          associations = model.reflect_on_all_associations(:belongs_to).reject do |association|
            association.options[:optional] == true # Excluded Optional Associations
          end

          return [] if associations.blank?

          associations.map do |association|
            if association.options[:class_name]
              constantize_class_name(association.options[:class_name], model.name)
            elsif association.polymorphic?
              types = find_polymorphic_types(model, association.name)

              if types.blank?
                puts "Polymorphic type not found for #{model.name}. Ignoring..."
                next
              end
            else
              association.klass
            end
          end.compact
        end

        def constantize_class_name(class_name, model_name)
          namespaced_class_name = if model_name.include?("::")
            "#{model_name.deconstantize}::#{class_name}"
          else
            class_name
          end
          begin
            namespaced_class_name.constantize
          rescue NameError
            # If the class_name with the namespace doesn't exist, try without the namespace
            puts "Class #{namespaced_class_name} not found. Trying without the namespace... #{class_name}"
            class_name.constantize
          end
        end
    end
  end
end
