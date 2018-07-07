module Appium
  module Core
    module Ios
      module Xcuitest
        module Device
          module Battery
            def self.add_methods
              ::Appium::Core::Device.add_endpoint_method(:battery_info) do
                def battery_info
                  response = execute_script 'mobile: batteryInfo', {}

                  state = case response['state']
                          when 1, 2, 3
                            ::Appium::Core::Base::Device::BatteryStatus::IOS[response['state']]
                          else
                            ::Appium::Logger.warn("The state is unknown or undefined: #{response['state']}")
                            ::Appium::Core::Base::Device::BatteryStatus::IOS[0] # :unknown
                          end
                  { state: state, level: response['level'] }
                end
              end
            end
          end # module Battery
        end # module Device
      end # module Xcuitest
    end # module Ios
  end # module Core
end # module Appium
