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

require_relative 'device/screen'

module Appium
  module Core
    module WinCore
      module Device
        extend Forwardable

        # @!method start_recording_screen(force_restart: nil, time_limit: nil, fps: nil, preset: nil, video_filter: nil, capture_clicks: nil, capture_cursor: nil, audio_input: nil)
        #   Record the Windows desktop. Leave capture_clicks and capture_cursor unset or false for WinCore's ffmpeg backend.
        # @!method stop_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT')
        #   Return the base64-encoded recording, or upload it to remote_path.

        class << self
          def extended(target)
            Screen.add_methods(target)
          end
        end # class << self
      end # module Device
    end # module WinCore
  end # module Core
end # module Appium
