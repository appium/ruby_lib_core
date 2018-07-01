module Appium
  module Core
    module Android
      module Uiautomator2
        module Device
          module Battery
            def self.add_methods
              ::Appium::Core::Device.add_endpoint_method(:battery_info) do
                def battery_info
                  response = execute_script 'mobile: batteryInfo', {}

                  state = case response['state']
                          when 2, 3, 4, 5
                            ::Appium::Core::Base::Device::BatteryStatus::ANDROID[response['state']]
                          else
                            ::Appium::Logger.warn("The state is unknown or undefined: #{response['state']}")
                            ::Appium::Core::Base::Device::BatteryStatus::ANDROID[1] # :unknown
                          end
                  { state: state, level: response['level'] }
                end
              end
            end
          end # module Battery
        end # module Device
      end # module Uiautomator2
    end # module Android
  end # module Core
end # module Appium
