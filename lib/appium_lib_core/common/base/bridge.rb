module Appium
  module Core
    class Base
      class Bridge < ::Selenium::WebDriver::Remote::Bridge
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

        def add_prefix(oss_capabilities)
          w3c_capabilities = ::Selenium::WebDriver::Remote::W3C::Capabilities.new

          oss_capabilities = oss_capabilities.__send__(:capabilities) unless oss_capabilities.is_a?(Hash)
          oss_capabilities.each do |name, value|
            next if value.nil?
            next if value.is_a?(String) && value.empty?

            capability_name = name.to_s

            snake_cased_capability_names = ::Selenium::WebDriver::Remote::W3C::Capabilities::KNOWN.map(&:to_s)
            camel_cased_capability_names = snake_cased_capability_names.map(&w3c_capabilities.method(:camel_case))

            unless snake_cased_capability_names.include?(capability_name) || camel_cased_capability_names.include?(capability_name)
              name = "appium:#{capability_name}"
            end

            w3c_capabilities[name] = value
          end

          w3c_capabilities
        end

        private

        # Use capabilities directory because Appium's capability is based on W3C one.
        # Called in bridge.create_session(desired_capabilities)
        def merged_capabilities(desired_capabilities)
          new_caps = add_prefix(desired_capabilities)
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
