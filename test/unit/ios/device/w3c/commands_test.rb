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
            @core ||= ::Appium::Core.for(self, Caps.ios)
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
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: { videoType: 'mp4', timeLimit: '180', videoQuality: 'medium' } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end

          def test_start_recording_screen_custom
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: { videoType: 'h265', timeLimit: '60', videoQuality: 'medium' } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen video_type: 'h265', time_limit: '60'

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
        end # class CommandsTest
      end # module W3C
    end # module Device
  end # module IOS
end # class AppiumLibCoreTest
