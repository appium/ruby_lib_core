module Appium
  module Core
    module Ios
      module Uiautomation
        module Device
          def self.add_methods
            # UiAutomation, Override included method in bridge
            ::Appium::Core::Device.add_endpoint_method(:hide_keyboard) do
              def hide_keyboard(close_key = nil, strategy = nil)
                option = {}

                option[:key] = close_key || 'Done'        # default to Done key.
                option[:strategy] = strategy || :pressKey # default to pressKey

                execute :hide_keyboard, {}, option
              end
            end

            # UiAutomation, Override included method in bridge
            ::Appium::Core::Device.add_endpoint_method(:background_app) do
              def background_app(duration = 0)
                execute :background_app, {}, seconds: duration
              end
            end
          end
        end # module Device
      end # module Uiautomation
    end # module Ios
  end # module Core
end # module Appium
