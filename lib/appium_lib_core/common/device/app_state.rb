module Appium
  module Core
    class Base
      module Device
        module AppState
          STATUS = [
            :not_installed,                   # 0
            :not_running,                     # 1
            :running_in_background_suspended, # 2
            :running_in_background,           # 3
            :running_in_foreground            # 4
          ].freeze

          def app_state(app_id)
            # required: [['appId'], ['bundleId']]
            response = execute :app_state, {}, appId: app_id

            case response
            when 0, 1, 2, 3, 4
              STATUS[response]
            else
              ::Appium::Logger.debug("Unexpected status in app_state: #{response}")
              response
            end
          end
        end # module AppState
      end # module Device
    end # class Base
  end # module Core
end # module Appium
