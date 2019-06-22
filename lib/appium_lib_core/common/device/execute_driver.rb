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
        module ExecuteDriver
          class Result
            attr_reader :result, :logs

            def initialize(response)
              @result = response['result']
              @logs = response['logs']
            end
          end

          def execute_driver(script: '', type: 'webdriverio', timeout_ms: nil)
            option = { script: script, type: type }

            option[:timeout] = timeout_ms if timeout_ms

            response = execute :execute_driver, {}, option
            Result.new(response)
          end
        end # module Execute
      end # module Device
    end # class Base
  end # module Core
end # module Appium
