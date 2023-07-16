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
        if File.exist?("config/seedie.yml")
          if ask_for_confirmation
            generate_seedie_file
          else
            say("Seedie installation aborted!", :red)
          end
        else
          generate_seedie_file
        end
      end

      private

      def ask_for_confirmation
        question = "A seedie.yml file already exists. Do you want to overwrite it? (y/n)"
        yes?(question)
      end

      def generate_seedie_file
        Rails.application.eager_load! # Load all models. This is required!!
        
        @models_config = models_configuration
        template "seedie.yml", "config/seedie.yml"
      end

      def models_configuration
        models = ActiveRecord::Base.descendants.reject do |model|
          EXCLUDED_MODELS.include?(model.name) || model.abstract_class?
        end

        models.reduce({}) do |config, model|
          config[model.name.underscore] = model_configuration(model)
          config
        end
      end

      def model_configuration(model)
        {
          "disabled_fields" => [],
          "attributes" => string_columns_configuration(model)
        }
      end

      def string_columns_configuration(model)
        string_columns = model.columns.select { |column| column.type == :string }.first(2)
        string_columns.reduce({}) do |config, column|
          config[column.name] = "#{column.name} {{index}}"
          config
        end
      end
    end
  end
end
