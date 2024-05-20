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
      class LocatorConverter
        def convert(how, what)
          [how, what]
        end
      end # LocatorConverter

      class Bridge < ::Selenium::WebDriver::Remote::Bridge
        include Device::DeviceLock
        include Device::Keyboard
        include Device::ImeActions
        include Device::Setting
        include Device::Context
        include Device::FileManagement
        include Device::KeyEvent
        include Device::ImageComparison
        include Device::AppManagement
        include Device::AppState
        include Device::ScreenRecord::Command
        include Device::Device
        include Device::ExecuteDriver
        include Device::Orientation

        Bridge.locator_converter = LocatorConverter.new

        # Prefix for extra capability defined by W3C
        APPIUM_PREFIX = 'appium:'

        # No 'browserName' means the session is native appium connection
        APPIUM_NATIVE_BROWSER_NAME = 'appium'

        attr_reader :available_commands

        def browser
          @browser ||= begin
            name = @capabilities&.browser_name
            name ? name.tr(' ', '_').downcase.to_sym : 'unknown'
          rescue KeyError
            APPIUM_NATIVE_BROWSER_NAME
          end
        end

        # Appium only.
        # Attach to an existing session.
        #
        # @param [String] The session id to attach to.
        # @param [String] platform_name The platform name to keep in the dummy capabilities
        # @param [String] platform_name The automation name to keep in the dummy capabilities
        # @return [::Appium::Core::Base::Capabilities]
        #
        # @example
        #
        #   new_driver = ::Appium::Core::Driver.attach_to(
        #     driver.session_id,
        #     url: 'http://127.0.0.1:4723/wd/hub', automation_name: 'UiAutomator2', platform_name: 'Android'
        #   )
        #
        def attach_to(session_id, platform_name, automation_name)
          @available_commands = ::Appium::Core::Commands::COMMANDS.dup
          @session_id = session_id

          # generate a dummy capabilities instance which only has the given platformName and automationName
          @capabilities = ::Appium::Core::Base::Capabilities.new(
            'platformName' => platform_name,
            'automationName' => automation_name
          )
        end

        # Override
        # Creates session handling.
        #
        # @param [::Appium::Core::Base::Capabilities, Hash] capabilities A capability
        # @return [::Appium::Core::Base::Capabilities]
        #
        # @example
        #
        #   opts = {
        #     caps: {
        #       platformName: :ios,
        #       automationName: 'XCUITest',
        #       app: 'test/functional/app/UICatalog.app.zip',
        #       platformVersion: '11.4',
        #       deviceName: 'iPhone Simulator',
        #       useNewWDA: true,
        #     },
        #     appium_lib: {
        #       wait: 30
        #     }
        #   }
        #   core = ::Appium::Core.for(caps)
        #   driver = core.start_driver
        #
        def create_session(capabilities)
          @available_commands = ::Appium::Core::Commands::COMMANDS.dup

          always_match = add_appium_prefix(capabilities)
          response = execute(:new_session, {}, { capabilities: { alwaysMatch: always_match, firstMatch: [{}] } })

          @session_id = response['sessionId']
          raise ::Selenium::WebDriver::Error::WebDriverError, 'no sessionId in returned payload' unless @session_id

          @capabilities = json_create(response['capabilities'])
        end

        # Append +appium:+ prefix for Appium following W3C spec
        # https://www.w3.org/TR/webdriver/#dfn-validate-capabilities
        #
        # @param [::Appium::Core::Base::Capabilities, Hash] capabilities A capability
        # @return [::Appium::Core::Base::Capabilities]
        def add_appium_prefix(capabilities)
          w3c_capabilities = ::Appium::Core::Base::Capabilities.new

          capabilities = capabilities.send(:capabilities) unless capabilities.is_a?(Hash)

          capabilities.each do |name, value|
            capability_name = name.to_s
            w3c_name = extension_prefix?(capability_name) ? name : "#{APPIUM_PREFIX}#{capability_name}"

            w3c_capabilities[w3c_name] = value
          end

          w3c_capabilities
        end

        private

        def camel_case(str_or_sym)
          str_or_sym.to_s.gsub(/_([a-z])/) { Regexp.last_match(1).upcase }
        end

        def extension_prefix?(capability_name)
          snake_cased_capability_names = ::Appium::Core::Base::Capabilities::KNOWN.map(&:to_s)
          camel_cased_capability_names = snake_cased_capability_names.map { |v| camel_case(v) }

          # Check 'EXTENSION_CAPABILITY_PATTERN'
          snake_cased_capability_names.include?(capability_name) ||
            camel_cased_capability_names.include?(capability_name) ||
            capability_name.match(':')
        end

        def json_create(value)
          ::Appium::Core::Base::Capabilities.json_create(value)
        end

        public

        # command for Appium 2.0.

        # Example:
        #   driver.add_command(name: :available_contexts, method: :get, url: 'session/:session_id/contexts') do
        #     execute(:available_contexts, {}) || []
        #   end
        # Then,
        #   driver.available_contexts #=> ["NATIVE_APP"]

        # def add_command(method:, url:, name:, &block)
        #   Bridge.add_command name, method, url, &block
        # end

        def add_command(method:, url:, name:, &block)
          ::Appium::Logger.info "Overriding the method '#{name}' for '#{url}'" if @available_commands.key? name

          @available_commands[name] = [method, url]

          ::Appium::Core::Device.add_endpoint_method name, &block
        end

        def commands(command)
          @available_commands[command] || Bridge.extra_commands[command]
        end

        def status
          execute :status
        end

        # Perform 'touch' actions for W3C module.
        # Generate +touch+ pointer action here and users can use this via +driver.action+
        # - https://www.selenium.dev/documentation/webdriver/actions_api/
        # - https://www.selenium.dev/selenium/docs/api/rb/Selenium/WebDriver/ActionBuilder.html
        # - https://www.selenium.dev/selenium/docs/api/rb/Selenium/WebDriver/PointerActions.html
        # - https://www.selenium.dev/selenium/docs/api/rb/Selenium/WebDriver/KeyActions.html
        #
        # The pointer type is 'touch' by default in the Appium Ruby client.
        #
        # @example
        #
        #     element = @driver.find_element(:id, "some id")
        #     @driver.action.click(element).perform # The 'click' is a part of 'PointerActions'
        #
        def action(_deprecated_async = nil, async: false, devices: nil)
          ::Selenium::WebDriver::ActionBuilder.new(
            self,
            devices: devices || [::Selenium::WebDriver::Interactions.pointer(:touch, name: 'touch')],
            async: async,
            duration: 50 # milliseconds
          )
        end

        # Port from MJSONWP
        def get_timeouts
          execute :get_timeouts
        end

        # For Appium
        # override
        def element_displayed?(element)
          # For W3C
          # https://github.com/SeleniumHQ/selenium/commit/b618499adcc3a9f667590652c5757c0caa703289
          # execute_atom :isDisplayed, element
          execute :is_element_displayed, id: element.id
        end

        # For Appium
        # override
        def element_attribute(element, name)
          # For W3C in Selenium Client
          # execute_atom :getAttribute, element, name.
          # 'dom_attribute' in the WebDriver Selenium.
          execute :get_element_attribute, id: element.id, name: name
        end

        # For Appium
        alias switch_to_active_element active_element

        # For Appium
        # @param [Hash] id The id which can get as a response from server
        # @return [::Appium::Core::Element]
        def convert_to_element(id)
          ::Appium::Core::Element.new self, element_id_from(id)
        end

        # For Appium
        # override
        # called in 'extend DriverExtensions::HasNetworkConnection'
        def network_connection
          execute :get_network_connection
        end

        # For Appium
        # override
        # called in 'extend DriverExtensions::HasNetworkConnection'
        def network_connection=(type)
          execute :set_network_connection, {}, { parameters: { type: type } }
        end

        # For Appium
        # No implementation for W3C webdriver module
        # called in 'extend DriverExtensions::HasLocation'
        def location
          obj = execute(:get_location) || {}
          ::Appium::Location.new obj['latitude'], obj['longitude'], obj['altitude']
        end

        # For Appium
        # No implementation for W3C webdriver module
        def set_location(lat, lon, alt = 0.0, speed: nil, satellites: nil)
          loc = { latitude: lat, longitude: lon, altitude: alt }
          loc[:speed] = speed unless speed.nil?
          loc[:satellites] = satellites unless satellites.nil?
          execute :set_location, {}, { location: loc }
        end

        #
        # logs
        #
        # For Appium
        # No implementation for W3C webdriver module
        def available_log_types
          types = execute :get_available_log_types
          Array(types).map(&:to_sym)
        end

        # For Appium
        # No implementation for W3C webdriver module
        def log(type)
          data = execute :get_log, {}, { type: type.to_s }

          Array(data).map do |l|
            ::Selenium::WebDriver::LogEntry.new l.fetch('level', 'UNKNOWN'), l.fetch('timestamp'), l.fetch('message')
          rescue KeyError
            next
          end
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

        def viewport_screenshot
          execute_script('mobile: viewportScreenshot')
        end

        def element_screenshot(element_id)
          execute :take_element_screenshot, id: element_id
        end

        # for selenium-webdriver compatibility in chrome browser session.
        # This may be needed in selenium-webdriver 4.8 or over? (around the version)
        # when a session starts browserName: 'chrome' for bridge.
        # This method is not only for Android, but also chrome desktop browser as well.
        # So this bridge itself does not restrict the target module.
        def send_command(command_params)
          execute :chrome_send_command, {}, command_params
        end
      end # class Bridge
    end # class Base
  end # module Core
end # module Appium
