require "observer"

module Seedie
  module Reporters
    module Reportable
      include Observable

      def report(event_type, options = {})
        changed
        notify_observers(event_type, options)
      end

      def add_observers(observers)
        observers.each { |observer| add_observer(observer) }
      end
    end
  end
end
