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
        # TODO: Move W3C module to here

        # Prefix for extra capability defined by W3C
        APPIUM_PREFIX = 'appium:'

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
      end # class Bridge
    end # class Base
  end # module Core
end # module Appium
