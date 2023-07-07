module Reporters
  class ConsoleReporter < BaseReporter
    def initialize
      super($stdout)
    end

    def update(event_type, body)
      message = messages(event_type, body)
      @reports << message

      output.puts message
    end
  end
end