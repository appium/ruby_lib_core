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
    module Android
      module Uiautomator2
        module Device
          module Battery
            def self.add_methods
              ::Appium::Core::Device.add_endpoint_method(:battery_info) do
                def battery_info
                  response = execute_script 'mobile: batteryInfo', {}

                  state = case response['state']
                          when 2, 3, 4, 5
                            ::Appium::Core::Base::Device::BatteryStatus::ANDROID[response['state']]
                          else
                            ::Appium::Logger.warn("The state is unknown or undefined: #{response['state']}")
                            ::Appium::Core::Base::Device::BatteryStatus::ANDROID[1] # :unknown
                          end
                  { state: state, level: response['level'] }
                end
              end
            end
          end # module Battery
        end # module Device
      end # module Uiautomator2
    end # module Android
  end # module Core
end # module Appium
