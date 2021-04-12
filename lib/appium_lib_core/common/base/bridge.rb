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
      class Bridge < ::Selenium::WebDriver::Remote::Bridge
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
        include Device::Orientation

        # Prefix for extra capability defined by W3C
        APPIUM_PREFIX = 'appium:'

        # TODO: fixme
        def browser
          @browser ||= begin
            name = @capabilities.browser_name
            name ? name.tr(' ', '_').downcase.to_sym : 'unknown'
          rescue KeyError
            'unknown'
          end
        end

        # Override
        # Creates session handling both OSS and W3C dialects.
        #
        # @param [::Selenium::WebDriver::Remote::Capabilities, Hash] desired_capabilities A capability
        # @return [::Selenium::WebDriver::Remote::Capabilities]
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
        def create_session(desired_capabilities)
          caps = add_appium_prefix(desired_capabilities)
          response = execute(:new_session, {}, { capabilities: { firstMatch: [caps] } })

          @session_id = response['sessionId']
          capabilities = response['capabilities']

          raise ::Selenium::WebDriver::Error::WebDriverError, 'no sessionId in returned payload' unless @session_id

          @capabilities = json_create(capabilities)
        end

        # Append +appium:+ prefix for Appium following W3C spec
        # https://www.w3.org/TR/webdriver/#dfn-validate-capabilities
        #
        # @param [::Selenium::WebDriver::Remote::Capabilities, Hash] capabilities A capability
        # @return [::Selenium::WebDriver::Remote::Capabilities]
        def add_appium_prefix(capabilities)
          w3c_capabilities = ::Selenium::WebDriver::Remote::Capabilities.new

          capabilities = capabilities.__send__(:capabilities) unless capabilities.is_a?(Hash)

          capabilities.each do |name, value|
            next if value.nil?
            next if value.is_a?(String) && value.empty?

            capability_name = name.to_s
            w3c_name = extension_prefix?(capability_name) ? name : "#{APPIUM_PREFIX}#{capability_name}"

            w3c_capabilities[w3c_name] = value
          end

          w3c_capabilities
        end

        private

        def camel_case(str)
          str.gsub(/_([a-z])/) { Regexp.last_match(1).upcase }
        end

        def extension_prefix?(capability_name)
          snake_cased_capability_names = ::Selenium::WebDriver::Remote::Capabilities::KNOWN.map(&:to_s)
          camel_cased_capability_names = snake_cased_capability_names.map { |v| camel_case(v) }

          # Check 'EXTENSION_CAPABILITY_PATTERN'
          snake_cased_capability_names.include?(capability_name) ||
            camel_cased_capability_names.include?(capability_name) ||
            capability_name.match(':')
        end

        def json_create(value)
          ::Selenium::WebDriver::Remote::Capabilities.json_create(value)
        end

        public

        def commands(command)
          ::Appium::Core::Commands::COMMANDS[command]
        end

        # Returns all available sessions on the Appium server instance
        def sessions
          execute :get_all_sessions
        end

        def status
          execute :status
        end

        # Perform touch actions for W3C module.
        # Generate +touch+ pointer action here and users can use this via +driver.action+
        # - https://seleniumhq.github.io/selenium/docs/api/rb/Selenium/WebDriver/W3CActionBuilder.html
        # - https://seleniumhq.github.io/selenium/docs/api/rb/Selenium/WebDriver/PointerActions.html
        # - https://seleniumhq.github.io/selenium/docs/api/rb/Selenium/WebDriver/KeyActions.html
        #
        # 'mouse' action is by default in the Ruby client. Appium server force the +mouse+ action to +touch+ once in
        # the server side. So we don't consider the case.
        #
        # @example
        #
        #     element = @driver.find_element(:id, "some id")
        #     @driver.action.click(element).perform # The 'click' is a part of 'PointerActions'
        #
        def action(async = false)
          # Used for default duration of each touch actions
          # Override from 250 milliseconds to 50 milliseconds
          action_builder = super
          action_builder.default_move_duration = 0.05
          action_builder
        end

        # Port from MJSONWP
        def get_timeouts
          execute :get_timeouts
        end

        # Port from MJSONWP
        def session_capabilities
          ::Selenium::WebDriver::Remote::Capabilities.json_create execute(:get_capabilities)
        end

        # Port from MJSONWP
        def send_keys_to_active_element(key)
          text = ::Selenium::WebDriver::Keys.encode(key).join('')
          execute :send_keys_to_active_element, {}, { value: text.split(//) }
        end

        # For Appium
        # override
        def page_source
          # For W3C
          # execute_script('var source = document.documentElement.outerHTML;' \
          # 'if (!source) { source = new XMLSerializer().serializeToString(document); }' \
          # 'return source;')
          execute :get_page_source
        end

        # For Appium
        # override
        def element_displayed?(element)
          # For W3C
          # https://github.com/SeleniumHQ/selenium/commit/b618499adcc3a9f667590652c5757c0caa703289
          # execute_atom :isDisplayed, element
          execute :is_element_displayed, id: element.ref
        end

        # For Appium
        # override
        def element_attribute(element, name)
          # For W3C in Selenium Client
          # execute_atom :getAttribute, element, name
          execute :get_element_attribute, id: element.ref, name: name
        end

        # For Appium
        # override
        def active_element
          ::Appium::Core::Element.new self, element_id_from(execute(:get_active_element))
        end
        alias switch_to_active_element active_element

        # For Appium
        # override
        def find_element_by(how, what, parent = nil)
          how, what = convert_locators(how, what)

          id = if parent
                 execute :find_child_element, { id: parent }, { using: how, value: what }
               else
                 execute :find_element, {}, { using: how, value: what }
               end
          ::Appium::Core::Element.new self, element_id_from(id)
        end

        # For Appium
        # override
        def find_elements_by(how, what, parent = nil)
          how, what = convert_locators(how, what)

          ids = if parent
                  execute :find_child_elements, { id: parent }, { using: how, value: what }
                else
                  execute :find_elements, {}, { using: how, value: what }
                end

          ids.map { |id| ::Appium::Core::Element.new self, element_id_from(id) }
        end

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
          ::Selenium::WebDriver::Location.new obj['latitude'], obj['longitude'], obj['altitude']
        end

        # For Appium
        # No implementation for W3C webdriver module
        def set_location(lat, lon, alt = 0.0, speed: nil)
          loc = { latitude: lat, longitude: lon, altitude: alt }
          loc[:speed] = speed unless speed.nil?
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
            begin
              ::Selenium::WebDriver::LogEntry.new l.fetch('level', 'UNKNOWN'), l.fetch('timestamp'), l.fetch('message')
            rescue KeyError
              next
            end
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

        def take_viewport_screenshot
          execute_script('mobile: viewportScreenshot')
        end

        def take_element_screenshot(element)
          execute :take_element_screenshot, id: element.ref
        end

        private

        def unwrap_script_result(arg)
          case arg
          when Array
            arg.map { |e| unwrap_script_result(e) }
          when Hash
            element_id = element_id_from(arg)
            return ::Appium::Core::Element.new(self, element_id) if element_id

            arg.each { |k, v| arg[k] = unwrap_script_result(v) }
          else
            arg
          end
        end

        def element_id_from(id)
          id['ELEMENT'] || id['element-6066-11e4-a52e-4f735466cecf']
        end

        # Don't convert locators for Appium Client
        # TODO: Only for Appium. Ideally, we'd like to keep the selenium-webdriver
        def convert_locators(how, what)
          # case how
          # when 'class name'
          #   how = 'css selector'
          #   what = ".#{escape_css(what)}"
          # when 'id'
          #   how = 'css selector'
          #   what = "##{escape_css(what)}"
          # when 'name'
          #   how = 'css selector'
          #   what = "*[name='#{escape_css(what)}']"
          # when 'tag name'
          #   how = 'css selector'
          # end
          [how, what]
        end
      end # class Bridge
    end # class Base
  end # module Core
end # module Appium
