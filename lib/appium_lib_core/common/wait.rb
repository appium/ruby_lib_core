# rubocop:disable Lint/HandleExceptions
module Appium
  module Core
    class Wait
      class TimeoutError < StandardError; end

      require 'timeout' # for wait

      DEFAULT_TIMEOUT  = 5
      DEFAULT_INTERVAL = 0.2

      # @example
      #
      #     Appium::Core::Wait.until { @driver.find_element(:id, 'something') }
      #
      def self.until(timeout: DEFAULT_TIMEOUT, interval: DEFAULT_INTERVAL, message: nil, ignored: nil, return_if_true: nil)
        ignored = Array(ignored || ::Exception)

        end_time   = Time.now + timeout
        last_error = nil

        until Time.now > end_time
          begin
            return yield unless return_if_true

            result = yield
            return result if result
          rescue ::Errno::ECONNREFUSED => e
            raise e
          rescue *ignored => last_error
            # swallowed
          end

          sleep interval
        end

        msg = message ? message.dup : "timed out after #{timeout} seconds"

        msg << " (#{last_error.message})" if last_error

        raise TimeoutError, msg
      end

      # TODO
      # @driver.find_element(:id, 'something').wait_until(&:visible?).click
      # @driver.find_element(:id, 'something').wait_until_present #=> ??
    end # module Wait
  end # module Core
end # module Appium
