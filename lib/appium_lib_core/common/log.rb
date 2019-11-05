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
      #   @driver.logs.get 'syslog' # []
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

      # Add a custom log event which is available with <code>eventTimings</code> capabilities.
      # The events are in a part of <code>@driver.session_capabilities['events']</code>.
      #
      # @param [String] vendor The vendor prefix for the event
      # @param [String] event The name of event
      # @returns [nil]
      # @example
      #
      #   @driver.logs.event vendor: 'appium', event: 'funEvent'
      #   @driver.session_capabilities['events'] #=> {...., 'appium:funEvent' => [1572957315]}
      #
      #   @driver.logs.event vendor: 'appium', event: 'anotherEvent'
      #   @driver.session_capabilities['events'] #=> {...., 'appium:funEvent' => [1572957315],
      #                                          #          'appium:anotherEvent' => [1572959315]}
      #
      def event(vendor:, event:)
        @bridge.log_event vendor, event
      end
    end
  end # module Core
end # module Appium
