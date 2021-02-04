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

require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/ios/device/w3c/commands_test.rb
class AppiumLibCoreTest
  module Mac2
    module Device
      module W3C
        class CommandsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.mac2)
            @driver ||= mac2_mock_create_session_w3c
          end

          def test_start_recording_screen
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: { videoType: 'mjpeg', timeLimit: '180' } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end

          def test_start_recording_screen_custom
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: {
                videoType: 'libx264', timeLimit: '60',
                videoFps: '50', videoScale: '320:240', videoFilters: 'rotate=90', pixelFormat: 'yuv420p'
              } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen video_type: 'libx264', time_limit: '60',
                                           video_fps: '50', video_scale: '320:240', video_filters: 'rotate=90',
                                           pixel_format: 'yuv420p'

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end

          def test_stop_recording_screen_default
            stub_request(:post, "#{SESSION}/appium/stop_recording_screen")
              .with(body: {}.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.stop_recording_screen

            assert_requested(:post, "#{SESSION}/appium/stop_recording_screen", times: 1)
          end

          def test_stop_recording_screen_custom
            stub_request(:post, "#{SESSION}/appium/stop_recording_screen")
              .with(body: { options:
                                { remotePath: 'https://example.com', user: 'user name', pass: 'pass', method: 'PUT' } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.stop_recording_screen(remote_path: 'https://example.com', user: 'user name', pass: 'pass')

            assert_requested(:post, "#{SESSION}/appium/stop_recording_screen", times: 1)
          end

          def test_start_recording_screen_additional_options
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: {
                remotePath: 'https://example.com', method: 'PUT',
                fileFieldName: 'file', formFields: [%w(email example@mail.com), { file: 'another data' }],
                headers: { 'x-custom-header' => 'xxxxx' },
                videoType: 'mjpeg',
                timeLimit: '180'
              } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen remote_path: 'https://example.com', file_field_name: 'file',
                                           form_fields: [%w(email example@mail.com), { file: 'another data' }],
                                           headers: { 'x-custom-header': 'xxxxx' }

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end
        end # class CommandsTest
      end # module W3C
    end # module Device
  end # module Mac2
end # class AppiumLibCoreTest
