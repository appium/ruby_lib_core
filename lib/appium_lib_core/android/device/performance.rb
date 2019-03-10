# frozen_string_literal: true

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
