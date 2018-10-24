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

          def commands(command)
            ::Appium::Core::Commands::MJSONWP::COMMANDS[command]
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
        end # class MJSONWP
      end # class Bridge
    end # class Base
  end # module Core
end # module Appium
