module Appium
  module Core
    module Device
      module ImeActions
        def self.add_methods
          Appium::Core::Device.add_endpoint_method(:ime_activate) do
            def ime_activate(ime_name)
              # from Selenium::WebDriver::Remote::OSS
              execute :ime_activate_engine, {}, engine: ime_name
            end
          end

          Appium::Core::Device.add_endpoint_method(:ime_available_engines) do
            def ime_available_engines
              execute :ime_get_available_engines
            end
          end

          Appium::Core::Device.add_endpoint_method(:ime_active_engine) do
            # from Selenium::WebDriver::Remote::OSS
            def ime_active_engine
              execute :ime_get_active_engine
            end
          end

          Appium::Core::Device.add_endpoint_method(:ime_activated) do
            # from Selenium::WebDriver::Remote::OSS
            def ime_activated
              execute :ime_is_activated
            end
          end

          Appium::Core::Device.add_endpoint_method(:ime_deactivate) do
            # from Selenium::WebDriver::Remote::OSS
            def ime_deactivate
              execute :ime_deactivate, {}
            end
          end
        end
      end # module ImeActions
    end # module Device
  end # module Core
end # module Appium
