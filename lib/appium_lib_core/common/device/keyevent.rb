module Appium
  module Core
    class Base
      module Device
        module KeyEvent
          # Only for Selendroid
          def keyevent(key, metastate = nil)
            args             = { keycode: key }
            args[:metastate] = metastate if metastate
            execute :keyevent, {}, args
          end

          def press_keycode(key, metastate: [], flags: [])
            raise ArgumentError, 'flags should be Array' unless flags.is_a? Array
            raise ArgumentError, 'metastates should be Array' unless metastate.is_a? Array

            args             = { keycode: key }
            args[:metastate] = metastate.reduce(0) { |acc, meta| acc | meta } unless metastate.empty?
            args[:flags]     = flags.reduce(0) { |acc, flag| acc | flag } unless flags.empty?

            execute :press_keycode, {}, args
          end

          def long_press_keycode(key, metastate: [], flags: [])
            raise ArgumentError, 'flags should be Array' unless flags.is_a? Array
            raise ArgumentError, 'metastates should be Array' unless metastate.is_a? Array

            args             = { keycode: key }
            args[:metastate] = metastate.reduce(0) { |acc, meta| acc | meta } unless metastate.empty?
            args[:flags]     = flags.reduce(0) { |acc, flag| acc | flag } unless flags.empty?

            execute :long_press_keycode, {}, args
          end
        end # module KeyEvent
      end # module Device
    end # class Base
  end # module Core
end # module Appium
