require "rails/generators/base"
require "seedie"

module Seedie
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include PolymorphicAssociationHelper
      
      EXCLUDED_MODELS = %w[
        ActiveRecord::SchemaMigration
        ActiveRecord::InternalMetadata
        ActiveStorage::Attachment
        ActiveStorage::Blob
        ActiveStorage::VariantRecord
        ActionText::RichText
        ActionMailbox::InboundEmail
        ActionText::EncryptedRichText
      ]

      source_root File.expand_path("templates", __dir__)

      class_option :blank, type: :boolean, default: false, desc: "Generate a blank seedie.yml with examples"
      class_option :excluded_models, type: :array, default: [], desc: "Models to exclude from seedie.yml"
      class_option :include_only_models, type: :array, default: [], 
        desc: "Models to be specifically included in seedie.yml. This will ignore all other models."


      desc "Creates a seedie.yml for your application."
      def generate_seedie_file(output = STDOUT)
        if options[:include_only_models].present? && options[:excluded_models].present?
          raise ArgumentError, "Cannot use both --include_only_models and --excluded_models together." 
        end

        @excluded_models = options[:excluded_models] + EXCLUDED_MODELS
        @output = output

        if options[:blank]
          template "blank_seedie.yml", "config/seedie.yml"
        else
          Rails.application.eager_load! # Load all models. This is required!!

          @models = get_models
          @models_config = build_models_config
          template "seedie.yml", "config/seedie.yml"
        end

        output_seedie_warning
      end

      private

      def build_models_config
        models = Model::ModelSorter.new(@models).sort_by_dependency

        output_warning_for_extra_models(models)

        models.reduce({}) do |config, model|
          config[model.name.underscore] = model_configuration(model)
          config
        end
      end

      def model_configuration(model)
        attributes_configuration(model).merge(associations_configuration(model))
      end

      def attributes_configuration(model)
        active_columns = []
        disabled_columns = []
        default_columns = []
        foreign_keys = []
        polymorphic_types = []

        # Collect all foreign keys and polymorphic types
        model.reflect_on_all_associations.each do |assoc|
          foreign_keys << assoc.foreign_key
          polymorphic_types << assoc.foreign_type if assoc.options[:polymorphic]
        end

        model.columns.each do |column|
          # Excluding DEFAULT_DISABLED_FIELDS
          # Excluding foreign_keys, polymorphic associations,
          # password digest, columns with default functions or values
          next if ModelFields::DEFAULT_DISABLED_FIELDS.include?(column.name)
          next if column.name.end_with?("_id", "_digest")

          if polymorphic_types.include?(column.name) || foreign_keys.include?(column.name)
            next
          end
          
          # Adding default columns to default_columns
          if column.default.present? || column.default_function.present?
            default_columns << column
          elsif column.null == false || has_presence_validator?(model, column.name)
          # Only add to active if its required or has presence validator
            active_columns << column
          else
            disabled_columns << column
          end
        end

        # Add atleast one column to active columns
        active_columns << disabled_columns.pop if active_columns.empty? && disabled_columns.present?
        
        # Disable all default columns
        disabled_columns += default_columns

        {
          "attributes" => active_columns_configuration(model, active_columns),
          "disabled_fields" => disabled_columns_configuration(disabled_columns)
        }
      end

      def active_columns_configuration(model, columns)
        columns.reduce({}) do |config, column|
          validations = model.validators_on(column.name)
          config[column.name] = if validations.present?
                                  FieldValues::FakerBuilder.new(column.name, column, validations).build_faker_constant
                                else
                                  FieldValues::FakeValue.new(column.name, column).generate_fake_value
                                end
          config
        end
      end

      def disabled_columns_configuration(disabled_columns)
        disabled_columns.map(&:name)
      end

      def associations_configuration(model)
        {
          "associations" => {
            "belongs_to" => belongs_to_associations_configuration(model),
            "has_one" => {}, # TODO: Add has_one associations
            "has_many" => {}, # TODO: Add has_many associations
          }
        }
      end

      def belongs_to_associations_configuration(model)
        belongs_to_associations = model.reflect_on_all_associations(:belongs_to).reject do |association|
          association.options[:optional] == true # Excluded Optional Associations
        end

        unique_indexes = model.connection.indexes(model.table_name).select(&:unique).flat_map(&:columns)

        belongs_to_associations.reduce({}) do |config, association|
          if association.polymorphic?
            config[association.name.to_s] = set_polymorphic_association_config(model, association)
          else
            association_has_unique_index = unique_indexes.include?(association.foreign_key.to_s)
            config[association.name.to_s] = association_has_unique_index ? "unique" : "random"
          end
          config
        end
      end      
      
      def set_polymorphic_association_config(model, association)
        {
          "polymorphic" => find_polymorphic_types(model, association.name),
          "strategy" => "random"
        }
      end

      def has_presence_validator?(model, column_name)
        model.validators_on(column_name).any? { |v| v.kind == :presence }
      end

      def get_models
        @get_models ||= begin
          all_models = ActiveRecord::Base.descendants

          if options[:include_only_models].present?
            all_models.select! { |model| options[:include_only_models].include?(model.name) }
          end

          all_models.reject do |model|
            @excluded_models.include?(model.name) || # Excluded Reserved Models
            model.abstract_class? || # Excluded Abstract Models
            model.table_exists? == false || # Excluded Models without tables
            model.name.blank? || # Excluded Anonymous Models
            model.name.start_with?("HABTM_") # Excluded HABTM Models
          end
        end
      end

      def output_seedie_warning
        @output.puts "Seedie config file generated at config/seedie.yml"
        @output.puts "##################################################"
        @output.puts "WARNING: Please review the generated config file before running the seeds."
        @output.puts "There might be some things that you might need to change to ensure that the generated seeds run successfully."
        @output.puts "##################################################"
      end

      def output_warning_for_extra_models(models)
        if options[:excluded_models].present?
          required_excluded_models = models.map(&:name) & @excluded_models

          required_excluded_models.each do |model_name|
            @output.puts "WARNING: #{model_name} has dependencies with other models and cannot be excluded."
          end
        elsif options[:include_only_models].present?
          dependent_models = models.map(&:name) - @models.map(&:name)

          dependent_models.each do |model_name|
            @output.puts "WARNING: #{model_name} is a dependency of included models and needs to be included."
          end
        end
      end
    end
  end
end
