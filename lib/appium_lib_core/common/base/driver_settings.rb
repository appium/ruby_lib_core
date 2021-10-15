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
    class Base
      #
      # @api private
      #
      class DriverSettings
        # @private this class is private
        def initialize(bridge)
          @bridge = bridge
        end

        # Get appium Settings for current test session.
        #
        # @example
        #
        #   @driver.settings.get
        #
        def get
          @bridge.get_settings
        end

        # Update Appium Settings for current test session
        #
        # @param [Hash] settings Settings to update, keys are settings, values to value to set each setting to
        #
        # @example
        #
        #   @driver.settings.update({'allowInvisibleElements': true})
        #
        def update(settings)
          @bridge.update_settings(settings)
        end
      end
    end
  end
end
