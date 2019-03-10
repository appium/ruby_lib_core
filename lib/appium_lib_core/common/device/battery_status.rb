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
    class Base
      module Device
        module BatteryStatus
          ANDROID = [
            :undefined,    # 0, dummy
            :unknown,      # 1
            :charging,     # 2
            :discharging,  # 3
            :not_charging, # 4
            :full          # 5
          ].freeze

          IOS = [
            :unknown,      # 0
            :unplugged,    # 1
            :charging,     # 2
            :full          # 3
          ].freeze
        end # module BatteryStatus
      end # module Device
    end # class Base
  end # module Core
end # module Appium
