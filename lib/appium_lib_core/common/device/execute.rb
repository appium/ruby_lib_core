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
        module Execute
          def execute_driver(script: '', type: 'webdriverio', timeout: nil)
            option = {}

            option['script'] = script
            option['type'] = type
            option['timeout'] = timeout if timeout

            execute :execute_driver, {}, option
          end
        end # module Execute
      end # module Device
    end # class Base
  end # module Core
end # module Appium
