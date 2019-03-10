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
        module ImeActions
          def ime_activate(ime_name)
            execute :ime_activate_engine, {}, engine: ime_name
          end

          def ime_available_engines
            execute :ime_get_available_engines
          end

          def ime_active_engine
            execute :ime_get_active_engine
          end

          def ime_activated
            execute :ime_is_activated
          end

          def ime_deactivate
            execute :ime_deactivate, {}
          end
        end # module ImeActions
      end # module Device
    end # class Base
  end # module Core
end # module Appium
