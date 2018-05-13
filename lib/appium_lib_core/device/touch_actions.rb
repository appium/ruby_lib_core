module Appium
  module Core
    module Device
      module TouchActions
        def self.add_methods
          ::Appium::Core::Device.add_endpoint_method(:touch_actions) do
            def touch_actions(actions)
              actions = { actions: [actions].flatten }
              execute :touch_actions, {}, actions
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:multi_touch) do
            def multi_touch(actions)
              execute :multi_touch, {}, actions: actions
            end
          end
        end
      end # module TouchActions
    end # module Device
  end # module Core
end # module Appium
