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
    module Ios
      module Xcuitest
        module Device
          module Screen
            def self.add_methods
              ::Appium::Core::Device.add_endpoint_method(:start_recording_screen) do
                # rubocop:disable Metrics/ParameterLists
                def start_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT', force_restart: nil,
                                           video_type: 'mjpeg', time_limit: '180', video_quality: 'medium',
                                           video_fps: nil, video_scale: nil, video_filters: nil, pixel_format: nil)
                  option = ::Appium::Core::Base::Device::ScreenRecord.new(
                    remote_path: remote_path, user: user, pass: pass, method: method, force_restart: force_restart
                  ).upload_option

                  option[:videoType] = video_type
                  option[:timeLimit] = time_limit
                  option[:videoQuality] = video_quality

                  option[:videoFps] = video_fps unless video_fps.nil?
                  option[:videoScale] = video_scale unless video_scale.nil?
                  option[:videoFilters] = video_filters unless video_filters.nil?
                  option[:pixelFormat] = pixel_format unless pixel_format.nil?

                  execute(:start_recording_screen, {}, { options: option })
                end
                # rubocop:enable Metrics/ParameterLists
              end
            end
          end # module Screen
        end # module Device
      end # module Xcuitest
    end # module Ios
  end # module Core
end # module Appium
