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
        module Context
          def within_context(context)
            existing_context = current_context
            set_context context
            if block_given?
              result = yield
              set_context existing_context
              result
            else
              set_context existing_context
            end
          end

          def switch_to_default_context
            set_context nil
          end

          def current_context
            execute :current_context
          end

          def available_contexts
            # return empty array instead of nil on failure
            execute(:available_contexts, {}) || []
          end

          def set_context(context = null)
            execute :set_context, {}, name: context
          end
        end # module ImeActions
      end # module Device
    end # class Base
  end # module Core
end # module Appium
