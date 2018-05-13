module Appium
  module Core
    module Device
      module Setting
        def self.add_methods
          ::Appium::Core::Device.add_endpoint_method(:get_settings) do
            def get_settings
              execute :get_settings, {}
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:update_settings) do
            def update_settings(settings)
              execute :update_settings, {}, settings: settings
            end
          end
        end
      end # module Setting
    end # module Device
  end # module Core
end # module Appium
