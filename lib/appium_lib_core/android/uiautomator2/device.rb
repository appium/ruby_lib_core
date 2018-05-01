module Appium
  module Core
    module Android
      module Uiautomator2
        module Device
          extend Forwardable

          class << self
            def extended(_mod)
              ::Appium::Core::Device.extend_webdriver_with_forwardable

              # Override
              ::Appium::Core::Device.add_endpoint_method(:battery_info) do
                def battery_info
                  response = execute_script 'mobile: batteryInfo', {}

                  state = case response['state']
                          when 1, 2, 3, 4, 5
                            ::Appium::Core::Device::BatteryStatus::ANDROID[response['state']]
                          else
                            ::Appium::Core::Device::BatteryStatus::ANDROID[0] # :undefined
                          end
                  { state: state, level: response['level'] }
                end
              end
            end
          end # class << self
        end # module Device
      end # module Uiautomator2
    end # module Android
  end # module Core
end # module Appium
