module Appium
  module Core
    module Device
      module Keyboard
        def self.add_methods
          Appium::Core::Device.add_endpoint_method(:hide_keyboard) do
            def hide_keyboard(close_key = nil, strategy = nil)
              option = {}

              option[:key] = close_key || 'Done'        # default to Done key.
              option[:strategy] = strategy || :pressKey # default to pressKey

              execute :hide_keyboard, {}, option
            end
          end

          Appium::Core::Device.add_endpoint_method(:is_keyboard_shown) do
            def is_keyboard_shown # rubocop:disable Naming/PredicateName for compatibility
              execute :is_keyboard_shown
            end
          end
        end
      end # module Keyboard
    end # module Device
  end # module Core
end # module Appium
