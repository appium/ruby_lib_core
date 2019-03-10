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
      module Device
        module Network
          def self.add_methods
            ::Appium::Core::Device.add_endpoint_method(:get_network_connection) do
              def get_network_connection
                execute :get_network_connection
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:toggle_wifi) do
              def toggle_wifi
                execute :toggle_wifi
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:toggle_data) do
              def toggle_data
                execute :toggle_data
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:set_network_connection) do
              def set_network_connection(mode)
                # same as ::Selenium::WebDriver::DriverExtensions::HasNetworkConnection
                # But this method accept number
                connection_type = { airplane_mode: 1, wifi: 2, data: 4, all: 6, none: 0 }
                type = connection_type.key?(mode) ? connection_type[mode] : mode.to_i

                execute :set_network_connection, {}, type: type
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:toggle_airplane_mode) do
              def toggle_airplane_mode
                execute :toggle_airplane_mode
              end
              alias_method :toggle_flight_mode, :toggle_airplane_mode
            end
          end
        end # module Network
      end # module Device
    end # module Android
  end # module Core
end # module Appium
