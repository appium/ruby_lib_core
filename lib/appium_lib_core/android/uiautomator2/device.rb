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

require_relative 'device/battery'

module Appium
  module Core
    module Android
      module Uiautomator2
        module Device
          extend Forwardable

          # @since Appium 1.6.0
          # @!method battery_info
          #
          # Get battery information.
          #
          # @return [Hash]  Return battery level and battery state.
          #                 Battery level in range [0.0, 1.0], where 1.0 means 100% charge. -1 is returned
          #                 if the actual value cannot be retrieved from the system.
          #                 Battery state. The following symbols are possible
          #                 +:unknown, :charging, :discharging, :not_charging, :full+
          #
          # @example
          #
          #   @driver.battery_info #=> { state: :charging, level: 0.7 }
          #

          ####
          ## class << self
          ####

          class << self
            def extended(_mod)
              Battery.add_methods
            end
          end # class << self
        end # module Device
      end # module Uiautomator2
    end # module Android
  end # module Core
end # module Appium
