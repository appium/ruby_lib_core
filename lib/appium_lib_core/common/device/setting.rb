module Appium
  module Core
    class Base
      module Device
        module Setting
          def get_settings
            execute :get_settings, {}
          end

          def update_settings(settings)
            execute :update_settings, {}, settings: settings
          end
        end # module Setting
      end # module Device
    end # class Base
  end # module Core
end # module Appium
