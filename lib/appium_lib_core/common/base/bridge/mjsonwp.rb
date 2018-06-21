module Appium
  module Core
    class Base
      class Bridge
        class MJSONWP < ::Selenium::WebDriver::Remote::OSS::Bridge
          def commands(command)
            ::Appium::Core::Commands::MJSONWP::COMMANDS[command]
          end

          def lock(duration = nil)
            opts = duration ? { seconds: duration } : {}
            execute :lock, {}, opts
          end

          def device_locked?
            execute :device_locked?
          end
          def unlock
            execute :unlock
          end
        end # class MJSONWP
      end # class Bridge
    end # class Base
  end # module Core
end # module Appium
