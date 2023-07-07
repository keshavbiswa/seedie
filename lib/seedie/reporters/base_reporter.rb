module Reporters
  class BaseReporter
    INDENT_SIZE = 2

    attr_reader :output, :reports

    def initialize(output = nil)
      @output = output || StringIO.new
      @reports = []
      @indent_level = 0
    end

    def update(event_type, options)
      raise NotImplementedError, "Subclasses must define 'update'."
    end

    def close
      return if output.closed?
      output.flush
    end

    private

    def messages(event_type, options)
      case event_type
      when :seed_start
        "############ SEEDIE RUNNING #############"
      when :seed_finish
        "############ SEEDIE FINISHED ############"
      when :model_seed_start
        "Seeding #{options[:name]}"
      when :model_seed_finish
        "Seeding #{options[:name]} finished!"
      when :record_created
        "Created #{options[:name]} with id: #{options[:id]}"
      when :has_many_start
        "Creating HasMany associations:"
      when :belongs_to_start
        "Creating BelongsTo associations:"
      when :has_one_start
        "Creating HasOne associations:"
      when :associated_records
        "Creating #{options[:count]} #{options[:name]} for #{options[:parent_name]}"
      when :random_association
        "Randomly associating #{options[:name]} with id: #{options[:id]} for #{options[:parent_name]}"
      when :belongs_to_associations
        "Creating a new #{options[:name].titleize} for #{options[:parent_name]}"
      else
        "Unknown event type"
      end
    end

    def indent_level_for(event_type)
      indent_levels = {
        seed_start: 0, 
        seed_finish: 0, 
        model_seed_start: 1, 
        model_seed_finish: 1, 
        record_created: 1, 
        random_association: 1,
        has_many_start: 2, 
        belongs_to_start: 2, 
        has_one_start: 2, 
        associated_records: 3, 
        belongs_to_associations: 3
      }

      indent_levels[event_type]
    end

    def set_indent_level(event_type)
      if event_type.in?([:record_created, :random_association])
        @indent_level += 1 if !@reports.last[:event_type].in?([:record_created, :random_association])
      elsif @reports.blank? || @reports.last[:event_type] != event_type
        @indent_level = indent_level_for(event_type)
      end
    end
  end
end