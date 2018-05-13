module Appium
  module Core
    module Device
      module Value
        def self.add_methods
          ::Appium::Core::Device.add_endpoint_method(:set_immediate_value) do
            def set_immediate_value(element, *value)
              keys = ::Selenium::WebDriver::Keys.encode(value)
              execute :set_immediate_value, { id: element.ref }, value: Array(keys)
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:replace_value) do
            def replace_value(element, *value)
              keys = ::Selenium::WebDriver::Keys.encode(value)
              execute :replace_value, { id: element.ref }, value: Array(keys)
            end
          end
        end
      end # module Value
    end # module Device
  end # module Core
end # module Appium
