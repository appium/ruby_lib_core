module Appium
  module Core
    class Base
      module Device
        module Value
          def set_immediate_value(element, *value)
            keys = ::Selenium::WebDriver::Keys.encode(value)
            execute :set_immediate_value, { id: element.ref }, value: Array(keys)
          end

          def replace_value(element, *value)
            keys = ::Selenium::WebDriver::Keys.encode(value)
            execute :replace_value, { id: element.ref }, value: Array(keys)
          end
        end # module Value
      end # module Device
    end # class Base
  end # module Core
end # module Appium
