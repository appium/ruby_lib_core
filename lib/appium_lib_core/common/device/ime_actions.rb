module Appium
  module Core
    class Base
      module Device
        module ImeActions
          def ime_activate(ime_name)
            execute :ime_activate_engine, {}, engine: ime_name
          end

          def ime_available_engines
            execute :ime_get_available_engines
          end

          def ime_active_engine
            execute :ime_get_active_engine
          end

          def ime_activated
            execute :ime_is_activated
          end

          def ime_deactivate
            execute :ime_deactivate, {}
          end
        end # module ImeActions
      end # module Device
    end # class Base
  end # module Core
end # module Appium
