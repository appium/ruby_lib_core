require_relative '../touch_action/touch_actions'
require_relative '../touch_action/multi_touch'

module Appium
  module Core
    class Base
      module Device
        module TouchActions
          def touch_actions(actions)
            actions = { actions: [actions].flatten }
            execute :touch_actions, {}, actions
          end

          def multi_touch(actions)
            execute :multi_touch, {}, actions: actions
          end
        end # module TouchActions
      end # module Device
    end # class Base
  end # module Core
end # module Appium
