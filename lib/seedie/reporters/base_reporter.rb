module Reporters
  class BaseReporter
    attr_reader :output, :reports

    def initialize(output = nil)
      @output = output || StringIO.new
      @reports = []
    end

    def update(event_type, body)
      raise NotImplementedError, "Subclasses must define 'update'."
    end

    def close
      return if output.closed?
      output.flush
    end

    private

    def messages(event_type, body)
      case event_type
      when :seed_start
        "############ SEEDIE RUNNING #############"
      when :seed_finish
        "############ SEEDIE FINISHED ############"
      when :model_seed_start
        "Creating #{body[:name]}"
      when :model_seed_finish
        "Seeding #{body[:name]} finished!"
      when :record_created
        "Created #{body[:name]} with id: #{body[:id]}"
      when :has_many_start
        "Creating HasMany associations:"
      when :associated_records
        "Creating #{body[:count]} #{body[:name]} for #{body[:parent_name]}"
      when :belongs_to_start
        "Creating BelongsTo associations:"
      when :random_association
        "Randomly associating #{body[:name]} with id: #{body[:id]} for #{body[:parent_name]}"
      when :belongs_to_associations
        "Creating a new #{body[:name].titleize} for #{body[:parent_name]}"
      when :has_one_start
        "Creating HasOne associations:"
      else
        "Unknown event type"
      end
    end
  end
end