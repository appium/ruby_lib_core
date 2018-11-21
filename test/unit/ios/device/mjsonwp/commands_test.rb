require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/ios/device/mjsonwp/commands_test.rb
class AppiumLibCoreTest
  module IOS
    module Device
      module MJSONWP
        class CommandsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.ios)
            @driver ||= ios_mock_create_session
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

          # Screen recording

          def test_start_recording_screen
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: { videoType: 'mjpeg', timeLimit: '180', videoQuality: 'medium' } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end

          def test_start_recording_screen_custom
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: {
                videoType: 'libx264', timeLimit: '60', videoQuality: 'medium', videoScale: '320:240'
              } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen video_type: 'libx264', time_limit: '60', video_scale: '320:240'

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end

          def test_start_recording_screen_custom_force
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body:
                { options: { forceRestart: true, videoType: 'libx264', timeLimit: '60', videoQuality: 'medium' } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen video_type: 'libx264', time_limit: '60', force_restart: true

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

          def test_get_battery_info
            stub_request(:post, "#{SESSION}/execute")
              .with(body: { script: 'mobile: batteryInfo', args: [{}] }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: { state: 3, level: 1.0 } }.to_json)

            info = @driver.battery_info

            assert_requested(:post, "#{SESSION}/execute", times: 1)
            assert_equal :full, info[:state]
            assert_equal 1.0, info[:level]
          end
        end # class CommandsTest
      end # module MJSONWP
    end # module Device
  end # module IOS
end # class AppiumLibCoreTest
