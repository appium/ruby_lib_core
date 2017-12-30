module Appium
  module Core
    class Base
      class Bridge < ::Selenium::WebDriver::Remote::Bridge
        # Prefix for extra capability defined by W3C
        APPIUM_PREFIX = 'appium:'.freeze

        # Almost same as self.handshake in ::Selenium::WebDriver::Remote::Bridge
        #
        # Implements protocol handshake which:
        #
        #   1. Creates session with driver.
        #   2. Sniffs response.
        #   3. Based on the response, understands which dialect we should use.
        #
        # @return [CoreBridgeMJSONWP, CoreBridgeW3C]
        #
        def self.handshake(**opts)
          desired_capabilities = opts.delete(:desired_capabilities)

          if desired_capabilities.is_a?(Symbol)
            unless Remote::Capabilities.respond_to?(desired_capabilities)
              raise Error::WebDriverError, "invalid desired capability: #{desired_capabilities.inspect}"
            end
            desired_capabilities = Remote::Capabilities.__send__(desired_capabilities)
          end

          bridge = new(opts)
          capabilities = bridge.create_session(desired_capabilities)

          case bridge.dialect
          when :oss # for MJSONWP
            CoreBridgeMJSONWP.new(capabilities, bridge.session_id, opts)
          when :w3c
            CoreBridgeW3C.new(capabilities, bridge.session_id, opts)
          else
            raise CoreError, 'cannot understand dialect'
          end
        end

        # Override
        # Creates session handling both OSS and W3C dialects.
        # Copy from Selenium::WebDriver::Remote::Bridge to keep using `merged_capabilities` for Appium
        #
        # @param [::Selenium::WebDriver::Remote::W3C::Capabilities, Hash] capabilities A capability
        # @return [::Selenium::WebDriver::Remote::Capabilities, ::Selenium::WebDriver::Remote::W3C::Capabilities]
        #
        def create_session(desired_capabilities)
          response = execute(:new_session, {}, merged_capabilities(desired_capabilities))

          @session_id = response['sessionId']
          oss_status = response['status']
          value = response['value']

          if value.is_a?(Hash)
            @session_id = value['sessionId'] if value.key?('sessionId')

            if value.key?('capabilities')
              value = value['capabilities']
            elsif value.key?('value')
              value = value['value']
            end
          end

          unless @session_id
            raise Error::WebDriverError, 'no sessionId in returned payload'
          end

          json_create(oss_status, value)
        end

        # Append `appium:` prefix for Appium following W3C spec
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
            w3c_name = appium_prefix?(capability_name, w3c_capabilities) ? name : "#{APPIUM_PREFIX}#{capability_name}"

            w3c_capabilities[w3c_name] = value
          end

          w3c_capabilities
        end

        private

        def appium_prefix?(capability_name, w3c_capabilities)
          snake_cased_capability_names = ::Selenium::WebDriver::Remote::W3C::Capabilities::KNOWN.map(&:to_s)
          camel_cased_capability_names = snake_cased_capability_names.map(&w3c_capabilities.method(:camel_case))

          snake_cased_capability_names.include?(capability_name) ||
            camel_cased_capability_names.include?(capability_name) ||
            capability_name.start_with?(APPIUM_PREFIX)
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

        # Called in bridge.create_session(desired_capabilities) from Parent class
        def merged_capabilities(desired_capabilities)
          new_caps = add_appium_prefix(desired_capabilities)
          w3c_capabilities = ::Selenium::WebDriver::Remote::W3C::Capabilities.from_oss(new_caps)

          {
            desiredCapabilities: desired_capabilities,
            capabilities: {
              firstMatch: [w3c_capabilities]
            }
          }
        end
      end # class Bridge
    end # class Base
  end # module Core
end # module Appium
