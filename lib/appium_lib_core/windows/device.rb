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
        # @!method start_recording_screen(remote_path: nil, user: nil, pass: nil, method: nil, force_restart: nil, video_type: 'mjpeg', video_fps: nil, time_limit: '180', video_quality: 'medium', video_scale: nil, video_filters: nil, pixel_format: nil)
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
        # @param [Boolean] force_restart Whether to try to catch and upload/return the currently running screen recording
        #                                (+false+, the default setting on server) or ignore the result of it
        #                                and start a new recording immediately (+true+).
        # @param [String] video_type The video codec type used for encoding of the be recorded screen capture.
        #                            Execute +ffmpeg -codecs+ in the terminal to see the list of supported video codecs.
        #                            'mjpeg' by default.
        # @param [String] time_limit Recording time. 180 seconds is by default.
        # @param [String] video_quality The video encoding quality (low, medium, high, photo - defaults to medium).
        # @param [String] video_fps The Frames Per Second rate of the recorded video. Change this value if the resulting video
        #                           is too slow or too fast. Defaults to 10. This can decrease the resulting file size.
        # @param [String] video_filters - @since Appium 1.15.0
        #                                 The ffmpeg video filters to apply. These filters allow to scale, flip, rotate and do many
        #                                 other useful transformations on the source video stream. The format of the property
        #                                 must comply with https://ffmpeg.org/ffmpeg-filters.html
        #                                 e.g.: "rotate=90"
        # @param [String] video_scale The scaling value to apply. Read https://trac.ffmpeg.org/wiki/Scaling for possible values.
        #                             No scale is applied by default.
        #                             tips: ffmpeg cannot capture video as +libx264+ if the video dimensions is not divisible by 2.
        #                             Then, you can set this scale as +scale=trunc(iw/2)*2:trunc(ih/2)*2+
        #                             - https://github.com/appium/appium/issues/12856
        #                             - https://www.reddit.com/r/linux4noobs/comments/671z6b/width_not_divisible_by_2_error_when_using_ffmpeg/
        # @param [String] pixel_format Output pixel format. Run +ffmpeg -pix_fmts+ to list possible values.
        #                              For Quicktime compatibility, set to "yuv420p" along with videoType: "libx264".
        #
        # @example
        #
        #    @driver.start_recording_screen
        #    @driver.start_recording_screen video_type: 'mjpeg', time_limit: '260'
        #    @driver.start_recording_screen video_type: 'libx264', time_limit: '260' # Can get '.mp4' video
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
