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
  module IOS
    module Device
      module W3C
        class CommandsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.ios)
            @driver ||= ios_mock_create_session_w3c
          end

          def test_touch_id
            stub_request(:post, "#{SESSION}/appium/simulator/touch_id")
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.touch_id

            assert_requested(:post, "#{SESSION}/appium/simulator/touch_id", times: 1)
          end

          def test_toggle_touch_id_enrollment
            stub_request(:post, "#{SESSION}/appium/simulator/toggle_touch_id_enrollment")
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.toggle_touch_id_enrollment(true)

            assert_requested(:post, "#{SESSION}/appium/simulator/toggle_touch_id_enrollment", times: 1)
          end

          def test_start_recording_screen
            skip 'Only XCUITest supports' unless @core.automation_name == :xcuitest

            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: { videoType: 'mjpeg', timeLimit: '180' } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end

          def test_start_recording_screen_custom
            skip 'Only XCUITest supports' unless @core.automation_name == :xcuitest

            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: {
                videoType: 'libx264', timeLimit: '60',
                videoFps: '50', videoScale: '320:240', videoFilters: 'rotate=90', pixelFormat: 'yuv420p'
              } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen(video_type: 'libx264', time_limit: '60',
                                           video_fps: '50', video_scale: '320:240', video_filters: 'rotate=90',
                                           pixel_format: 'yuv420p')

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end

          def test_stop_recording_screen_default
            skip 'Only XCUITest supports' unless @core.automation_name == :xcuitest

            stub_request(:post, "#{SESSION}/appium/stop_recording_screen")
              .with(body: {}.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.stop_recording_screen

            assert_requested(:post, "#{SESSION}/appium/stop_recording_screen", times: 1)
          end

          def test_stop_recording_screen_custom
            skip 'Only XCUITest supports' unless @core.automation_name == :xcuitest

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

            @driver.start_recording_screen(remote_path: 'https://example.com', file_field_name: 'file',
                                           form_fields: [%w(email example@mail.com), { file: 'another data' }],
                                           headers: { 'x-custom-header': 'xxxxx' })

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end

          def test_get_battery_info
            skip 'Only XCUITest supports' unless @core.automation_name == :xcuitest

            stub_request(:post, "#{SESSION}/execute/sync")
              .with(body: { script: 'mobile: batteryInfo', args: [{}] }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: { state: 1, level: 0.5 } }.to_json)

            info = @driver.battery_info

            assert_requested(:post, "#{SESSION}/execute/sync", times: 1)
            assert_equal :unplugged, info[:state]
            assert_equal 0.5, info[:level]
          end

          def test_method_missing
            stub_request(:get, "#{SESSION}/element/id/attribute/name")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            e = ::Selenium::WebDriver::Element.new(@driver.send(:bridge), 'id')
            e.name

            assert_requested(:get, "#{SESSION}/element/id/attribute/name", times: 1)
          end

          def test_background_app
            if @core.automation_name == :xcuitest
              stub_request(:post, "#{SESSION}/appium/app/background")
                .with(body: { seconds: { timeout: 0 } }.to_json)
                .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)
            else
              stub_request(:post, "#{SESSION}/appium/app/background")
                .with(body: { seconds: 0 }.to_json)
                .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)
            end

            @driver.background_app 0

            assert_requested(:post, "#{SESSION}/appium/app/background", times: 1)
          end
        end # class CommandsTest
      end # module W3C
    end # module Device
  end # module IOS
end # class AppiumLibCoreTest
