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
      def generate_seedie_file(output = STDOUT)
        Rails.application.eager_load! # Load all models. This is required!!

        @models = get_models
        @models_config = build_models_config
        template "seedie.yml", "config/seedie.yml"
        output_seedie_warning(output)
      end

      private


      def build_models_config
        models = Model::ModelSorter.new(@models).sort_by_dependency
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

        model.columns.each do |column|
          # Excluding DEFAULT_DISABLED_FIELDS
          # Excluding foreign_keys, polymorphic associations,
          # password digest, columns with default functions or values
          next if ModelFields::DEFAULT_DISABLED_FIELDS.include?(column.name)
          next if column.name.end_with?("_id", "_type", "_digest")
          next if column.default_function.present?
          next if column.default.present?
      
          # Only add to active if its required or has presence validator
          if column.null == false || has_presence_validator?(model, column.name)
            active_columns << column
          else
            disabled_columns << column
          end
        end

        # Add atleast one column to active columns
        active_columns << disabled_columns.pop if active_columns.empty? && disabled_columns.present?

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

        belongs_to_associations.reduce({}) do |config, association|
          if association.polymorphic?
            config[association.name.to_s] = set_polymorphic_association_config(model, association)
          else
            config[association.name.to_s] = "random"
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

      def find_polymorphic_types(model, association_name)
        types = @models.select do |potential_poly_model|
          potential_poly_model.reflect_on_all_associations(:has_many).any? do |has_many_association|
            has_many_association.options[:as] == association_name
          end
        end.map(&:name)

        types.size == 1 ? types.first.underscore : types.map(&:underscore)
      end

      def has_presence_validator?(model, column_name)
        model.validators_on(column_name).any? { |v| v.kind == :presence }
      end

      def get_models
        @get_models ||= ActiveRecord::Base.descendants.reject do |model|
          EXCLUDED_MODELS.include?(model.name) || # Excluded Reserved Models
          model.abstract_class? || # Excluded Abstract Models
          model.table_exists? == false || # Excluded Models without tables
          model.name.blank? || # Excluded Anonymous Models
          model.name.start_with?("HABTM_") # Excluded HABTM Models
        end
      end

      def output_seedie_warning(output)
        output.puts "Seedie config file generated at config/seedie.yml"
        output.puts "##################################################"
        output.puts "WARNING: Please review the generated config file before running the seeds."
        output.puts "There might be some things that you might need to change to ensure that the generated seeds run successfully."
        output.puts "##################################################"
      end
    end
  end
end
