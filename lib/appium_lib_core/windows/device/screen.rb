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
    module Windows
      module Device
        module Screen
          def self.add_methods
            ::Appium::Core::Device.add_endpoint_method(:start_recording_screen) do
              def start_recording_screen(force_restart: nil, time_limit: nil,
                                         fps: nil, preset: nil, video_filter: nil,
                                         capture_clicks: nil, capture_cursor: nil, audio_input: nil)
                option = {}
                option[:forceRestart] = force_restart unless force_restart.nil?
                option[:timeLimit] = time_limit unless time_limit.nil?
                option[:fps] = fps unless fps.nil?
                option[:preset] = preset unless preset.nil?
                option[:videoFilter] = video_filter unless video_filter.nil?
                option[:captureClicks] = capture_clicks unless capture_clicks.nil?
                option[:captureCursor] = capture_cursor unless capture_cursor.nil?
                option[:audioInput] = audio_input unless audio_input.nil?

                execute(:start_recording_screen, {}, { options: option })
              end
            end
          end
        end # module Screen
      end # module Device
    end # module Windows
  end # module Core
end # module Appium
