module Appium
  module Core
    class Base
      module Device
        module Device
          def shake
            execute :shake
          end

          def device_time(format = nil)
            arg = {}
            arg[:format] = format unless format.nil?
            execute :device_time, {}, arg
          end
        end # module Device
      end # module Device
    end # class Base
  end # module Core
end # module Appium
