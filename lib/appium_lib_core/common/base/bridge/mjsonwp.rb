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
      class Bridge
        class MJSONWP < ::Selenium::WebDriver::Remote::OSS::Bridge
          include Device::DeviceLock
          include Device::Keyboard
          include Device::ImeActions
          include Device::Setting
          include Device::Context
          include Device::Value
          include Device::FileManagement
          include Device::KeyEvent
          include Device::ImageComparison
          include Device::AppManagement
          include Device::AppState
          include Device::ScreenRecord::Command
          include Device::Device
          include Device::TouchActions
          include Device::ExecuteDriver

          attr_reader :available_commands

          def initialize(capabilities, session_id, **opts)
            @available_commands = ::Appium::Core::Commands::MJSONWP::COMMANDS.dup
            super(capabilities, session_id, **opts)
          end

          def commands(command)
            @available_commands[command]
          end

          # command for Appium 2.0.
          def add_command(method:, url:, name:, &block)
            ::Appium::Logger.debug "Overriding the method '#{name}' for '#{url}'" if @available_commands.key? name

            @available_commands[name] = [method, url]

            ::Appium::Core::Device.add_endpoint_method name, &block
          end

          # Returns all available sessions on the Appium server instance
          def sessions
            execute :get_all_sessions
          end

          def status
            execute :status
          end

          # For Appium
          def log_event(vendor, event)
            execute :post_log_event, {}, { vendor: vendor, event: event }
          end

          # For Appium
          def log_events(type = nil)
            args = {}
            args['type'] = type unless type.nil?

            execute :get_log_events, {}, args
          end

          def take_element_screenshot(element)
            execute :take_element_screenshot, id: element.ref
          end

          def take_viewport_screenshot
            # TODO: this hasn't been supported by Espresso driver
            execute_script('mobile: viewportScreenshot')
          end

          def send_actions(_data)
            raise Error::UnsupportedOperationError, '#send_actions has not been supported in MJSONWP'
          end

          # For Appium
          # @param [Hash] id The id which can get as a response from server
          # @return [::Selenium::WebDriver::Element]
          def convert_to_element(id)
            ::Selenium::WebDriver::Element.new self, element_id_from(id)
          end

          def set_location(lat, lon, alt = 0.0, speed: nil, satellites: nil)
            loc = { latitude: lat, longitude: lon, altitude: alt }
            loc[:speed] = speed unless speed.nil?
            loc[:satellites] = satellites unless satellites.nil?
            execute :set_location, {}, { location: loc }
          end
        end # class MJSONWP
      end # class Bridge
    end # class Base
  end # module Core
end # module Appium
