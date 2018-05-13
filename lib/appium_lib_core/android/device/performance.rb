module Appium
  module Core
    module Android
      module Device
        module Performance
          def self.add_methods
            ::Appium::Core::Device.add_endpoint_method(:get_performance_data_types) do
              def get_performance_data_types
                execute :get_performance_data_types
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:get_performance_data) do
              def get_performance_data(package_name:, data_type:, data_read_timeout: 1000)
                execute(:get_performance_data, {},
                        packageName: package_name, dataType: data_type, dataReadTimeout: data_read_timeout)
              end
            end
          end
        end # module Performance
      end # module Device
    end # module Android
  end # module Core
end # module Appium
