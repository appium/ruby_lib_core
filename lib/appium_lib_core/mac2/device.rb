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
    module Mac2
      module Device
        extend Forwardable

        # rubocop:disable Layout/LineLength

        # @since Appium 1.20.0
        # @!method start_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT', file_field_name: nil, form_fields: nil, headers: nil, force_restart: nil, fps: nil, preset: nil, video_filter: nil, enable_capture_clicks: nil, enable_cursor_capture: nil, device_id: nil)
        #
        # Record the display of devices running iOS Simulator since Xcode 9 or real devices since iOS 11
        # (ffmpeg utility is required: 'brew install ffmpeg').
        # We would recommend to play the video by VLC or Mplayer if you can not play the video with other video players.
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
        # @param [String] file_field_name The name of the form field containing the binary payload in multipart/form-data
        #                             requests since Appium 1.18.0. Defaults to 'file'.
        # @param [Array<Hash, Array<String>>] form_fields The form fields mapping in multipart/form-data requests since Appium 1.18.0.
        #                             If any entry has the same key in this mapping, then it is going to be ignored.
        # @param [Hash] headers The additional headers in multipart/form-data requests since Appium 1.18.0.
        # @param [Boolean] force_restart Whether to try to catch and upload/return the currently running screen recording
        #                                (+false+, the default setting on server) or ignore the result of it
        #                                and start a new recording immediately (+true+).
        # @param [integer] fps The count of frames per second in the resulting video.
        #                      Increasing fps value also increases the size of the resulting video file and the CPU usage.
        #                      The default value is 15.
        # @param [String] preset A preset is a collection of options that will provide a certain encoding speed to compression ratio.
        #                        A slower preset will provide better compression (compression is quality per filesize).
        #                        This means that, for example, if you target a certain file size or constant bit rate, you will
        #                        achieve better quality with a slower preset. Read https://trac.ffmpeg.org/wiki/Encode/H.264
        #                        for more details.
        # @param [Boolean] enable_cursor_capture Whether to capture the click gestures while recording the screen. Disabled by default.
        # @param [Boolean] enable_capture_clicks Recording time. 180 seconds is by default.
        # @param [String] video_filter The video filter spec to apply for ffmpeg.
        #                              See https://trac.ffmpeg.org/wiki/FilteringGuide for more details on the possible values.
        #                              Example: Set it to +scale=ifnot(gte(iw\,1024)\,iw\,1024):-2+ in order to limit the video width
        #                              to 1024px. The height will be adjusted automatically to match the actual screen aspect ratio.
        # @param [integer] device_id Screen device index to use for the recording.
        #                                 The list of available devices could be retrieved using
        #                                 +ffmpeg -f avfoundation -list_devices true -i+ command.
        #                                 This option is mandatory and must be always provided.
        # @param [String] time_limit The maximum recording time. The default value is 600 seconds (10 minutes).
        #                            The minimum time resolution unit is one second.
        #
        # @example
        #
        #    @driver.start_recording_screen
        #    @driver.start_recording_screen fps: 30, enable_cursor_capture: true
        #

        # rubocop:enable Layout/LineLength

        ####
        ## class << self
        ####

        class << self
          def extended(_mod)
            Screen.add_methods
          end
        end # class << self
      end # module Device
    end # module Mac2
  end # module Core
end # module Appium
