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
    module Windows
      module Device
        module AppManagement
          # override
          def self.add_methods
            ::Appium::Core::Device.add_endpoint_method(:launch_app) do
              def launch_app
                execute :launch_app
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:close_app) do
              def close_app
                execute :close_app
              end
            end
          end
        end # module AppManagement
      end # module Device
    end # module Windows
  end # module Core
end # module Appium
