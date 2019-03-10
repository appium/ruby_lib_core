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
    module Wait
      class Timer
        def initialize(timeout)
          @end_time = current_time + timeout
        end

        def timeout?
          current_time > @end_time
        end

        if defined?(Process::CLOCK_MONOTONIC)
          def current_time
            Process.clock_gettime(Process::CLOCK_MONOTONIC)
          end
        else
          def current_time
            ::Time.now.to_f
          end
        end
      end # class Timer
    end # module Wait
  end # module Core
end # module Appium
