module Appium
  module Core
    class Logs
      def initialize(bridge)
        @bridge = bridge
      end

      # @param [String|Hash] type You can get particular type's logs.
      # @return [[Selenium::WebDriver::LogEntry]] A list of logs data.
      #
      # @example
      #
      #   @driver.logs.get "syslog" # []
      #   @driver.logs.get :syslog # []
      #
      def get(type)
        @bridge.log type
      end

      # Get a list of available log types
      #
      # @return [[Hash]] A list of available log types.
      # @example
      #
      #   @driver.logs.available_types # [:syslog, :crashlog, :performance]
      #
      def available_types
        @bridge.available_log_types
      end
    end
  end # module Core
end # module Appium
