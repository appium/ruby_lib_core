module Appium
  module Core
    module Device
      module KeyEvent
        def self.add_methods
          # Only for Selendroid
          ::Appium::Core::Device.add_endpoint_method(:keyevent) do
            def keyevent(key, metastate = nil)
              args             = { keycode: key }
              args[:metastate] = metastate if metastate
              execute :keyevent, {}, args
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:press_keycode) do
            def press_keycode(key, metastate: [], flags: [])
              raise ArgumentError, 'flags should be Array' unless flags.is_a? Array
              raise ArgumentError, 'metastates should be Array' unless metastate.is_a? Array

              args             = { keycode: key }
              args[:metastate] = metastate.reduce(0) { |acc, meta| acc | meta } unless metastate.empty?
              args[:flags]     = flags.reduce(0) { |acc, flag| acc | flag } unless flags.empty?

              execute :press_keycode, {}, args
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:long_press_keycode) do
            def long_press_keycode(key, metastate: [], flags: [])
              raise ArgumentError, 'flags should be Array' unless flags.is_a? Array
              raise ArgumentError, 'metastates should be Array' unless metastate.is_a? Array

              args             = { keycode: key }
              args[:metastate] = metastate.reduce(0) { |acc, meta| acc | meta } unless metastate.empty?
              args[:flags]     = flags.reduce(0) { |acc, flag| acc | flag } unless flags.empty?

              execute :long_press_keycode, {}, args
            end
          end
        end
      end # module KeyEvent
    end # module Device
  end # module Core
end # module Appium
