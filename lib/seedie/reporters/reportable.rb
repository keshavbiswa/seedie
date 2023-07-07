require "observer"

module Reporters
  module Reportable
    include Observable

    def notify(event_type, body = {})
      changed
      notify_observers(event_type, body)
    end

    def add_observers(observers)
      observers.each { |observer| add_observer(observer) }
    end
  end
end