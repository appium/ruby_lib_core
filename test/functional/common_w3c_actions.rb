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

# Scroll action for Android and iOS following W3C spec
def w3c_scroll(driver)
  window = driver.window_rect

  action_builder = driver.action
  input = action_builder.pointer_inputs[0]
  action_builder
    .move_to_location(window.width / 2, window.height * 8 / 10)
    .pointer_down(:left)
    .pause(device: input, duration: 0.1)
    .move_to_location(window.width / 2, window.height / 10, duration: 0.2)
    .pause(device: input, duration: 0.1)
    .release
    .perform
end
