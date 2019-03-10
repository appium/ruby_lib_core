# frozen_string_literal: true

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
