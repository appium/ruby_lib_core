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

require_relative '../touch_action/touch_actions'
require_relative '../touch_action/multi_touch'

module Appium
  module Core
    class Base
      module Device
        module TouchActions
          def touch_actions(actions)
            actions = { actions: [actions].flatten }
            execute :touch_actions, {}, actions
          end

          def multi_touch(actions)
            execute :multi_touch, {}, actions: actions
          end
        end # module TouchActions
      end # module Device
    end # class Base
  end # module Core
end # module Appium
