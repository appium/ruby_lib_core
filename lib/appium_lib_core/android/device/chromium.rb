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

require 'base64'

module Appium
  module Core
    module Android
      module Device
        module Chromium
          def self.add_methods
            ::Appium::Core::Device.add_endpoint_method(:chromium_network_conditions) do
              def chromium_network_conditions
                execute :chromium_get_network_conditions
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:chromium_network_conditions=) do
              def chromium_network_conditions=(conditions)
                execute :chromium_set_network_conditions, {}, { network_conditions: conditions }
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:chromium_available_log_types) do
              def chromium_available_log_types
                types = execute :chromium_get_available_log_types
                Array(types).map(&:to_sym)
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:chromium_log) do
              def chromium_log(type)
                data = execute :chromium_get_log, {}, { type: type.to_s }

                Array(data).map do |l|
                  begin
                    ::Selenium::WebDriver::LogEntry.new l.fetch('level', 'UNKNOWN'), l.fetch('timestamp'), l.fetch('message')
                  rescue KeyError
                    next
                  end
                end
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:chromium_send_cdp_command) do
              def chromium_send_cdp_command(command_params)
                execute :chromium_send_command, {}, command_params
              end
            end
          end
        end # module Chromium
      end # module Device
    end # module Android
  end # module Core
end # module Appium
