module Appium
  module Core
    class Base
      class CoreBridgeMJSONWP < ::Selenium::WebDriver::Remote::OSS::Bridge
        def commands(command)
          ::Appium::Core::Commands::COMMANDS_EXTEND_MJSONWP[command]
        end
      end # class CoreBridgeMJSONWP
    end # class Base
  end # module Core
end # module Appium
