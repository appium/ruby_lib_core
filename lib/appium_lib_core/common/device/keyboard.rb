module Appium
  module Core
    class Base
      module Device
        module Keyboard
          def hide_keyboard(close_key = nil, strategy = nil)
            option = {}

            option[:key] = close_key || 'Done'        # default to Done key.
            option[:strategy] = strategy || :pressKey # default to pressKey

            execute :hide_keyboard, {}, option
          end

          def is_keyboard_shown # rubocop:disable Naming/PredicateName
            execute :is_keyboard_shown
          end
        end # module Keyboard
      end # module Device
    end # class Base
  end # module Core
end # module Appium
