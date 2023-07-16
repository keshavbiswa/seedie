require "rails/generators/base"
require "active_record"

module Seedie
  module Generators
    class InstallGenerator < Rails::Generators::Base
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

      desc "Creates a seedie.yml for your application."
      def copy_seedie_file
        generate_seedie_file
      end

      private

      def generate_seedie_file
        Rails.application.eager_load! # Load all models. This is required!!
        
        @models_config = models_configuration
        template "seedie.yml", "config/seedie.yml"
      end

      def models_configuration
        models = ActiveRecord::Base.descendants.reject do |model|
          EXCLUDED_MODELS.include?(model.name) || # Excluded Reserved Models
          model.table_exists? == false || # Excluded Models without tables
          model.abstract_class? || # Excluded Abstract Models
          model.name.blank? || # Excluded Anonymous Models
          model.name.start_with?("HABTM_") # Excluded HABTM Models
        end

        models = Model::ModelSorter.new(models).sort_by_dependency
        models.reduce({}) do |config, model|
          config[model.name.underscore] = model_configuration(model)
          config
        end
      end      

      def model_configuration(model)
        {
          "disabled_fields" => [],
          "attributes" => string_columns_configuration(model),
          "associations" => {
            "belongs_to" => belongs_to_associations_configuration(model),
            "has_one" => {},
            "has_many" => {},
          }
        }
      end

      def belongs_to_associations_configuration(model)
        belongs_to_associations = model.reflect_on_all_associations(:belongs_to).reject do |association|
          association.options[:polymorphic] == true || # Excluded Polymorphic Associations
          association.options[:optional] == true || # Excluded Optional Associations
          association.options[:through] != nil || # Excluded Through Associations
          association.options[:foreign_key] != nil || # Excluded Custom Foreign Key Associations
          association.options[:class_name] != nil # Excluded Custom Class Name Associations
        end

        belongs_to_associations.reduce({}) do |config, association|
          config[association.name.to_s] = "random"
          config
        end
      end

      def string_columns_configuration(model)
        string_columns = model.columns.reject do |column|
          ModelFields::DEFAULT_DISABLED_FIELDS.include?(column.name) || # Excluded reserved columns
          column.name.end_with?("_id") || # Excluded foreign key columns
          column.name.end_with?("_type") || # Excluded polymorphic columns
          column.name.end_with?("_digest") || # Excluded password digest columns
          column.name.end_with?("_token") # Excluded remember token columns
        end
        
        string_columns.reduce({}) do |config, column|
          config[column.name] = FieldValues::FakeValue.new(column.name, column).generate_fake_value
          config
        end
      end
    end
  end
end
