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
        # Prefix for extra capability defined by W3C
        APPIUM_PREFIX = 'appium:'

        # TODO: Remove the forceMjsonwp after Appium server won't need it
        FORCE_MJSONWP = :forceMjsonwp

        # Almost same as self.handshake in ::Selenium::WebDriver::Remote::Bridge
        #
        # Implements protocol handshake which:
        #
        #   1. Creates session with driver.
        #   2. Sniffs response.
        #   3. Based on the response, understands which dialect we should use.
        #
        # @return [Bridge::MJSONWP, Bridge::W3C]
        #
        def self.handshake(**opts)
          desired_capabilities = opts.delete(:desired_capabilities) { ::Selenium::WebDriver::Remote::Capabilities.new }

          if desired_capabilities.is_a?(Symbol)
            unless ::Selenium::WebDriver::Remote::Capabilities.respond_to?(desired_capabilities)
              raise ::Selenium::WebDriver::Error::WebDriverError, "invalid desired capability: #{desired_capabilities.inspect}"
            end

            desired_capabilities = ::Selenium::WebDriver::Remote::Capabilities.__send__(desired_capabilities)
          end

          bridge = new(opts)
          capabilities = bridge.create_session(desired_capabilities)

          case bridge.dialect
          when :oss # for MJSONWP
            Bridge::MJSONWP.new(capabilities, bridge.session_id, opts)
          when :w3c
            Bridge::W3C.new(capabilities, bridge.session_id, opts)
          else
            raise CoreError, 'cannot understand dialect'
          end
        end

        # Override
        # Creates session handling both OSS and W3C dialects.
        # Copy from Selenium::WebDriver::Remote::Bridge to keep using +merged_capabilities+ for Appium
        #
        # If +desired_capabilities+ has +forceMjsonwp: true+ in the capability, this bridge works with mjsonwp protocol.
        # If +forceMjsonwp: false+ or no the capability, it depends on server side whether this bridge works as w3c or mjsonwp.
        #
        # @param [::Selenium::WebDriver::Remote::W3C::Capabilities, Hash] desired_capabilities A capability
        # @return [::Selenium::WebDriver::Remote::Capabilities, ::Selenium::WebDriver::Remote::W3C::Capabilities]
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
        #       forceMjsonwp: true
        #     },
        #     appium_lib: {
        #       wait: 30
        #     }
        #   }
        #   core = ::Appium::Core.for(caps)
        #   driver = core.start_driver #=> driver.dialect == :oss
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
        #   driver = core.start_driver #=> driver.dialect == :w3c if the Appium server support W3C.
        #
        def create_session(desired_capabilities)
          response = execute(:new_session, {}, merged_capabilities(desired_capabilities))

          @session_id = response['sessionId']
          oss_status = response['status'] # for compatibility with Appium 1.7.1-
          value = response['value']

          if value.is_a?(Hash) # include for W3C format
            @session_id = value['sessionId'] if value.key?('sessionId')

            if value.key?('capabilities')
              value = value['capabilities']
            elsif value.key?('value')
              value = value['value']
            end
          end

          raise ::Selenium::WebDriver::Error::WebDriverError, 'no sessionId in returned payload' unless @session_id

          json_create(oss_status, value)
        end

        # Append +appium:+ prefix for Appium following W3C spec
        # https://www.w3.org/TR/webdriver/#dfn-validate-capabilities
        #
        # @param [::Selenium::WebDriver::Remote::W3C::Capabilities, Hash] capabilities A capability
        # @return [::Selenium::WebDriver::Remote::W3C::Capabilities]
        def add_appium_prefix(capabilities)
          w3c_capabilities = ::Selenium::WebDriver::Remote::W3C::Capabilities.new

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
          snake_cased_capability_names = ::Selenium::WebDriver::Remote::W3C::Capabilities::KNOWN.map(&:to_s)
          camel_cased_capability_names = snake_cased_capability_names.map { |v| camel_case(v) }

          snake_cased_capability_names.include?(capability_name) ||
            camel_cased_capability_names.include?(capability_name) ||
            capability_name.match(::Selenium::WebDriver::Remote::W3C::Capabilities::EXTENSION_CAPABILITY_PATTERN)
        end

        def json_create(oss_status, value)
          if oss_status
            ::Selenium::WebDriver.logger.info 'Detected OSS dialect.'
            @dialect = :oss
            ::Selenium::WebDriver::Remote::Capabilities.json_create(value)
          else
            ::Selenium::WebDriver.logger.info 'Detected W3C dialect.'
            @dialect = :w3c
            ::Selenium::WebDriver::Remote::W3C::Capabilities.json_create(value)
          end
        end

        def delete_force_mjsonwp(capabilities)
          w3c_capabilities = ::Selenium::WebDriver::Remote::W3C::Capabilities.new

          capabilities = capabilities.__send__(:capabilities) unless capabilities.is_a?(Hash)
          capabilities.each do |name, value|
            next if value.nil?
            next if value.is_a?(String) && value.empty?
            next if name == FORCE_MJSONWP

            w3c_capabilities[name] = value
          end

          w3c_capabilities
        end

        def merged_capabilities(desired_capabilities)
          force_mjsonwp = desired_capabilities[FORCE_MJSONWP]
          desired_capabilities = delete_force_mjsonwp(desired_capabilities) unless force_mjsonwp.nil?

          if force_mjsonwp
            {
              desiredCapabilities: desired_capabilities
            }
          else
            new_caps = add_appium_prefix(desired_capabilities)
            w3c_capabilities = ::Selenium::WebDriver::Remote::W3C::Capabilities.from_oss(new_caps)

            {
              desiredCapabilities: desired_capabilities,
              capabilities: {
                firstMatch: [w3c_capabilities]
              }
            }
          end
        end
      end # class Bridge
    end # class Base
  end # module Core
end # module Appium
