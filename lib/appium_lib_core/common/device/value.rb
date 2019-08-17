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
            execute :set_immediate_value, { id: element.ref }, generate_value_and_text(value)
          end

          def replace_value(element, *value)
            execute :replace_value, { id: element.ref }, generate_value_and_text(value)
          end

          private

          def generate_value_and_text(*value)
            keys = ::Selenium::WebDriver::Keys.encode(*value)

            if @file_detector
              local_files = keys.first.split("\n").map { |key| @file_detector.call(Array(key)) }.compact
              if local_files.any?
                keys = local_files.map { |local_file| upload(local_file) }
                keys = Array(keys.join("\n"))
              end
            end

            # Keep .split(//) for backward compatibility for now
            text = keys.join('')

            # FIXME: further work for W3C. Over appium 1.15.0 or later
            # { value: text.split(//), text: text }
            { value: text.split(//) }
          end
        end # module Value
      end # module Device
    end # class Base
  end # module Core
end # module Appium
