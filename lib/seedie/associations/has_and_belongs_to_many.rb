# frozen_string_literal: true

module Seedie
  module Associations
    class HasAndBelongsToMany < BaseAssociation
      def generate_associations
        return if association_config["has_and_belongs_to_many"].nil?

        report(:has_and_belongs_to_many_start)
        association_config["has_and_belongs_to_many"].each do |association_name, association_config|
          association_class = association_name.to_s.classify.constantize
          count = get_association_count(association_config)
          config = only_count_given?(association_config) ? {} : association_config

          report(:associated_records, name: association_name, count: count, parent_name: model.to_s)
          count.times do |index|
            field_values_set = FieldValuesSet.new(association_class, config, index).generate_field_values_with_associations
            record_creator = Model::Creator.new(record.send(association_name), reporters)

            record_creator.create!(field_values_set)
          end
        end
      end
    end
  end
end
