module Appium
  module Core
    module Android
      module Device
        module Network
          def self.add_methods
            ::Appium::Core::Device.add_endpoint_method(:get_network_connection) do
              def get_network_connection
                execute :get_network_connection
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:toggle_wifi) do
              def toggle_wifi
                execute :toggle_wifi
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:toggle_data) do
              def toggle_data
                execute :toggle_data
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:set_network_connection) do
              def set_network_connection(mode)
                # TODO. Update set_network_connection as well
                # connection_type = {airplane_mode: 1, wifi: 2, data: 4, all: 6, none: 0}
                # raise ArgumentError, 'Invalid connection type' unless type_to_values.keys.include? mode
                # type = connection_type[mode]
                # execute :set_network_connection, {}, type: type
                execute :set_network_connection, {}, type: mode
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:toggle_airplane_mode) do
              def toggle_airplane_mode
                execute :toggle_airplane_mode
              end
              alias_method :toggle_flight_mode, :toggle_airplane_mode
            end
          end
        end # module Network
      end # module Device
    end # module Android
  end # module Core
end # module Appium
