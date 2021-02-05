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
    module Mac2
      module Device
        module Screen
          def self.add_methods
            ::Appium::Core::Device.add_endpoint_method(:start_recording_screen) do
              def start_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT',
                                         file_field_name: nil, form_fields: nil, headers: nil, force_restart: nil,
                                         fps: nil, preset: nil, video_filter: nil, time_limit: nil,
                                         enable_capture_clicks: nil, enable_cursor_capture: nil, device_id: nil)
                option = ::Appium::Core::Base::Device::ScreenRecord.new(
                  remote_path: remote_path, user: user, pass: pass, method: method,
                  file_field_name: file_field_name, form_fields: form_fields, headers: headers,
                  force_restart: force_restart
                ).upload_option

                option[:fps] = fps unless fps.nil?
                option[:preset] = preset unless preset.nil?
                option[:videoFilter] = video_filter unless video_filter.nil?
                option[:captureClicks] = enable_capture_clicks unless enable_capture_clicks.nil?
                option[:captureCursor] = enable_cursor_capture unless enable_cursor_capture.nil?
                option[:deviceId] = device_id unless device_id.nil?
                option[:timeLimit] = time_limit unless time_limit.nil?

                execute(:start_recording_screen, {}, { options: option })
              end
            end
          end
        end # module Screen
      end # module Device
    end # module Mac2
  end # module Core
end # module Appium
