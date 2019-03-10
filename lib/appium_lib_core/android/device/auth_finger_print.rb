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
        module Authentication
          def self.add_methods
            ::Appium::Core::Device.add_endpoint_method(:finger_print) do
              def finger_print(finger_id)
                unless (1..10).cover? finger_id.to_i
                  raise ArgumentError, "finger_id should be integer between 1 to 10. Not #{finger_id}"
                end

                execute(:finger_print, {}, { fingerprintId: finger_id.to_i })
              end
            end
          end # def self.emulator_commands
        end # module Emulator
      end # module Device
    end # module Android
  end # module Core
end # module Appium
