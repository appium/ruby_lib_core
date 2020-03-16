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
    module Windows
      module Device
        extend Forwardable

        # rubocop:disable Metrics/LineLength

        # @since Appium 1.18.0
        # @!method start_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT', force_restart: nil, time_limit: nil, fps: nil, preset: nil, video_filter: nil, capture_clicks: nil, capture_cursor: nil, audio_input: nil)
        #
        # Record the display in background while the automated test is running.
        # This method requires FFMPEG (https://www.ffmpeg.org/download.html) to be installed and present in PATH.
        # The resulting video uses H264 codec and is ready to be played by media players built-in into web browsers.
        #
        # @param [Boolean] force_restart Whether to stop existing recording process forcefully and start a new recording process.
        # @param [String] time_limit Recording time. 600 seconds is by default.
        # @param [Number|String] fps The count of frames per second in the resulting video.
        #                            Increasing fps value also increases the size of the resulting
        #                            video file and the CPU usage. Defaults to 15.
        # @param [String] preset A preset is a collection of options that will provide a certain encoding speed to compression ratio.
        #                        A slower preset will provide better compression (compression is quality per filesize).
        #                        This means that, for example, if you target a certain file size or constant bit rate, you will
        #                        achieve better quality with a slower preset. Read https://trac.ffmpeg.org/wiki/Encode/H.264
        #                        for more details.
        #                        One of the supported encoding presets. Possible values are:
        #                          - ultrafast
        #                          - superfast
        #                          - veryfast (default)
        #                          - faster
        #                          - fast
        #                          - medium
        #                          - slow
        #                          - slower
        #                          - veryslow
        # @param [String] video_filter The video filter spec to apply for ffmpeg.
        #                              See https://trac.ffmpeg.org/wiki/FilteringGuide for more details on the possible values.
        #                              Example: Set it to +scale=ifnot(gte(iw\,1024)\,iw\,1024):-2+ in order to limit the video width
        #                              to 1024px. The height will be adjusted automatically to match the actual screen aspect ratio.
        # @param [Bool] capture_cursor Whether to capture the mouse cursor while recording the screen.
        #                              Disabled by default.
        # @param [Bool] capture_clicks Whether to capture the click gestures while recording the screen.
        #                              Disabled by default.
        # @param [String] audio_input If provided then the given audio input will be used to record the computer audio
        #                             along with the desktop video. The list of available devices could be retrieved using
        #                             +ffmpeg -list_devices true -f dshow -i dummy+ command.
        # @return [String] Base64 encoded content of the recorded media file
        #
        # @example
        #
        #    @driver.start_recording_screen
        #    @driver.start_recording_screen video_filter: 'scale=ifnot(gte(iw\,1024)\,iw\,1024):-2'
        #    @driver.start_recording_screen capture_cursor: true, capture_clicks: true, time_limit: '260'
        #

        # rubocop:enable Metrics/LineLength

        ####
        ## class << self
        ####

        class << self
          def extended(_mod)
            Screen.add_methods
          end
        end # class << self
      end # module Device
    end # module Windows
  end # module Core
end # module Appium
