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
