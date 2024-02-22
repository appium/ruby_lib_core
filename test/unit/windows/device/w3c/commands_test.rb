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
  module Windows
    module Device
      module W3C
        class CommandsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.windows)
            @driver ||= windows_mock_create_session_w3c
          end

          def test_start_recording_screen
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: {} }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end

          def test_start_recording_screen_custom
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: {
                timeLimit: '60', fps: 30, preset: 'faster', videoFilter: 'scale=ifnot(gte(iw\,1024)\,iw\,1024):-2',
                captureClicks: true, captureCursor: true, audioInput: 'dummy'
              } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen(
              time_limit: '60', fps: 30, preset: 'faster', video_filter: 'scale=ifnot(gte(iw\,1024)\,iw\,1024):-2',
              capture_clicks: true, capture_cursor: true, audio_input: 'dummy'
            )

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end

          def test_start_recording_screen_custom_force
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: {
                forceRestart: true,
                timeLimit: '60', fps: 30, preset: 'faster', videoFilter: 'scale=ifnot(gte(iw\,1024)\,iw\,1024):-2',
                captureClicks: true, captureCursor: true, audioInput: 'dummy'
              } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen(
              time_limit: '60', fps: 30, preset: 'faster', video_filter: 'scale=ifnot(gte(iw\,1024)\,iw\,1024):-2',
              capture_clicks: true, capture_cursor: true, audio_input: 'dummy',
              force_restart: true
            )

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
        end # class CommandsTest
      end # module W3C
    end # module Device
  end # module Windows
end # class AppiumLibCoreTest
