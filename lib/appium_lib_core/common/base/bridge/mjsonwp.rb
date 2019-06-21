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

          def commands(command)
            ::Appium::Core::Commands::MJSONWP::COMMANDS[command]
          end

          # Returns all available sessions on the Appium server instance
          def sessions
            execute :get_all_sessions
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
        end # class MJSONWP
      end # class Bridge
    end # class Base
  end # module Core
end # module Appium
