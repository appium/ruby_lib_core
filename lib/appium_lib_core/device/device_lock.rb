module Appium
  module Core
    module Device
      module DeviceLock
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
      end # module DeviceLock
    end # module Device
  end # module Core
end # module Appium
