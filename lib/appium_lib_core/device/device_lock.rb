module Appium
  module Core
    module Device
      module DeviceLock
        def self.add_methods
          ::Appium::Core::Device.add_endpoint_method(:lock) do
            def lock(duration = nil)
              opts = duration ? { seconds: duration } : {}
              execute :lock, {}, opts
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:device_locked?) do
            def device_locked?
              execute :device_locked?
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:unlock) do
            def unlock
              execute :unlock
            end
          end
        end
      end # module DeviceLock
    end # module Device
  end # module Core
end # module Appium
