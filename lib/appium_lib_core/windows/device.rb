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
        # @param [String] remote_path The path to the remote location, where the resulting video should be uploaded.
        #                             The following protocols are supported: http/https, ftp.
        #                             Null or empty string value (the default setting) means the content of resulting
        #                             file should be encoded as Base64 and passed as the endpount response value.
        #                             An exception will be thrown if the generated media file is too big to
        #                             fit into the available process memory.
        #                             This option only has an effect if there is screen recording process in progreess
        #                             and +forceRestart+ parameter is not set to +true+.
        # @param [String] user The name of the user for the remote authentication.
        # @param [String] pass The password for the remote authentication.
        # @param [String] method The http multipart upload method name. The 'PUT' one is used by default.
        # @param [Boolean] force_restart Whether to try to catch and upload/return the currently running screen recording
        #                                (+false+, the default setting on server) or ignore the result of it
        #                                and start a new recording immediately (+true+).
        # @param [String] time_limit Recording time. 180 seconds is by default.
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
