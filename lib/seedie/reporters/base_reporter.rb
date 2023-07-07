module Reporters
  class BaseReporter
    attr_reader :output

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
      end
    end
  end
end