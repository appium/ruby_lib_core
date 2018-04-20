module Appium
  module Core
    module Wait
      module Timer
        class << self
          # @private
          def wait(timeout, &block)
            end_time = current_time + timeout
            loop do
              yield(block)
              break if current_time > end_time
            end
          end

          private

          if defined?(Process::CLOCK_MONOTONIC)
            def current_time
              Process.clock_gettime(Process::CLOCK_MONOTONIC)
            end
          else
            def current_time
              ::Time.now.to_f
            end
          end
        end
      end # module Timer
    end # module Wait
  end # module Core
end # module Appium
