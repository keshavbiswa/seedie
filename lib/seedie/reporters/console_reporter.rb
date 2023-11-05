module Seedie
  module Reporters
    class ConsoleReporter < BaseReporter
      def initialize
        super($stdout)
      end

      def update(event_type, options)
        set_indent_level(event_type)
        message = messages(event_type, options)
        @reports << { event_type: event_type, message: message }

        output.print "#{" " * INDENT_SIZE * @indent_level}"
        output.puts message
      end
    end
  end
end
