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
    module Ios
      module Uiautomation
        module Device
          def self.add_methods
            # UiAutomation, Override included method in bridge
            ::Appium::Core::Device.add_endpoint_method(:hide_keyboard) do
              def hide_keyboard(close_key = nil, strategy = nil)
                option = {}

                option[:key] = close_key || 'Done'        # default to Done key.
                option[:strategy] = strategy || :pressKey # default to pressKey

                execute :hide_keyboard, {}, option
              end
            end

            # UiAutomation, Override included method in bridge
            ::Appium::Core::Device.add_endpoint_method(:background_app) do
              def background_app(duration = 0)
                execute :background_app, {}, seconds: duration
              end
            end
          end
        end # module Device
      end # module Uiautomation
    end # module Ios
  end # module Core
end # module Appium
