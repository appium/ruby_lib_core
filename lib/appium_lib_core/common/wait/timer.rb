module Appium
  module Core
    module Wait
      class Timer
        def initialize(timeout)
          @end_time = current_time + timeout
        end

        def timeout?
          current_time > @end_time
        end

        if defined?(Process::CLOCK_MONOTONIC)
          def current_time
            Process.clock_gettime(Process::CLOCK_MONOTONIC)
          end
        else
          def current_time
            ::Time.now.to_f
          end
        end
      end # class Timer
    end # module Wait
  end # module Core
end # module Appium
