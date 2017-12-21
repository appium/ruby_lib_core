module Appium
  module Core
    class Base
      class Bridge < ::Selenium::WebDriver::Remote::Bridge
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

          # case bridge.dialect
          # when :oss # for MJSONWP
          #   CoreBridgeMJSONWP.new(capabilities, bridge.session_id, opts)
          # when :w3c
            CoreBridgeW3C.new(capabilities, bridge.session_id, opts)
          # else
          #   raise CoreError, 'cannot understand dialect'
          # end
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
            w3c_name = appium_prefix?(capability_name, w3c_capabilities) ? name : "appium:#{capability_name}"

            w3c_capabilities[w3c_name] = value
          end

          w3c_capabilities
        end

        private

        APPIUM_PREFIX = 'appium:'.freeze
        def appium_prefix?(capability_name, w3c_capabilities)
          snake_cased_capability_names = ::Selenium::WebDriver::Remote::W3C::Capabilities::KNOWN.map(&:to_s)
          camel_cased_capability_names = snake_cased_capability_names.map(&w3c_capabilities.method(:camel_case))

          snake_cased_capability_names.include?(capability_name) ||
            camel_cased_capability_names.include?(capability_name) ||
            capability_name.start_with?(APPIUM_PREFIX)
        end

        # Use capabilities directory because Appium's capability is based on W3C one.
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

      class CoreBridgeMJSONWP < ::Selenium::WebDriver::Remote::OSS::Bridge
        def commands(command)
          ::Appium::Core::Commands::COMMANDS_EXTEND_MJSONWP[command]
        end
      end # class CoreBridgeMJSONWP

      class CoreBridgeW3C < ::Selenium::WebDriver::Remote::W3C::Bridge
        def commands(command)
          case command
          when :status, :is_element_displayed
            ::Appium::Core::Commands::COMMANDS_EXTEND_MJSONWP[command]
          else
            ::Appium::Core::Commands::COMMANDS_EXTEND_W3C[command]
          end
        end
      end # class CoreBridgeW3C
    end # class Base
  end # module Core
end # module Appium
