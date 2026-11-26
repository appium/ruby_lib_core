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
    module WinCore
      module Bridge
        def self.for(target)
          ::Appium::Core::Device.add_endpoint_method(:start_recording_screen, bridge: target.bridge_extensions) do
            # WinCore's ffmpeg backend expects capture_clicks and capture_cursor to be unset or false.
            def start_recording_screen(force_restart: nil, time_limit: nil, fps: nil, preset: nil, video_filter: nil,
                                       capture_clicks: nil, capture_cursor: nil, audio_input: nil)
              options = {
                forceRestart: force_restart, timeLimit: time_limit, videoFps: fps, preset: preset,
                videoFilter: video_filter, captureClicks: capture_clicks, captureCursor: capture_cursor, audioInput: audio_input
              }.compact
              execute_script('windows: startRecordingScreen', options)
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:stop_recording_screen, bridge: target.bridge_extensions) do
            def stop_recording_screen(**kwargs)
              options = ::Appium::Core::Base::Device::ScreenRecord.new(**kwargs).upload_option
              execute_script('windows: stopRecordingScreen', options)
            end
          end
        end
      end
    end
  end
end
