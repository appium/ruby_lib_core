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

# $ rake test:unit TEST=test/unit/android/device/w3c/commands_test.rb
class AppiumLibCoreTest
  module Android
    module Device
      module W3C
        class CommandsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_delete
            stub_request(:delete, SESSION)
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.quit

            assert_requested(:delete, SESSION, times: 1)
          end

          def test_shake
            stub_request(:post, "#{SESSION}/appium/device/shake")
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.shake

            assert_requested(:post, "#{SESSION}/appium/device/shake", times: 1)
          end

          def test_device_time
            stub_request(:get, "#{SESSION}/appium/device/system_time")
              .with(body: {}.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: 'device time' }.to_json)

            @driver.device_time

            assert_requested(:get, "#{SESSION}/appium/device/system_time", times: 1)
          end

          def test_device_time_with_format
            stub_request(:get, "#{SESSION}/appium/device/system_time")
              .with(body: { format: 'YYYY-MM-DD' }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: 'device time' }.to_json)

            @driver.device_time('YYYY-MM-DD')

            assert_requested(:get, "#{SESSION}/appium/device/system_time", times: 1)
          end

          def test_open_notifications
            stub_request(:post, "#{SESSION}/appium/device/open_notifications")
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.open_notifications

            assert_requested(:post, "#{SESSION}/appium/device/open_notifications", times: 1)
          end

          def test_toggle_airplane_mode
            stub_request(:post, "#{SESSION}/appium/device/toggle_airplane_mode")
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.toggle_airplane_mode

            assert_requested(:post, "#{SESSION}/appium/device/toggle_airplane_mode", times: 1)
          end

          def test_current_activity
            stub_request(:get, "#{SESSION}/appium/device/current_activity")
              .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

            @driver.current_activity

            assert_requested(:get, "#{SESSION}/appium/device/current_activity", times: 1)
          end

          def test_current_package
            stub_request(:get, "#{SESSION}/appium/device/current_package")
              .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

            @driver.current_package

            assert_requested(:get, "#{SESSION}/appium/device/current_package", times: 1)
          end

          def test_get_system_bars
            stub_request(:get, "#{SESSION}/appium/device/system_bars")
              .to_return(headers: HEADER, status: 200, body: { value: {
                statusBar: { visible: true, x: 0, y: 0, width: 1080, height: 63 },
                navigationBar: { visible: true, x: 0, y: 1794, width: 1080, height: 126 }
              } }.to_json)

            info = @driver.get_system_bars

            assert_requested(:get, "#{SESSION}/appium/device/system_bars", times: 1)
            assert_equal({ 'visible' => true, 'x' => 0, 'y' => 0, 'width' => 1080, 'height' => 63 }, info['statusBar'])
          end

          def test_get_display_density
            stub_request(:get, "#{SESSION}/appium/device/display_density")
              .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

            @driver.get_display_density

            assert_requested(:get, "#{SESSION}/appium/device/display_density", times: 1)
          end

          def test_get_network_connection
            stub_request(:get, "#{SESSION}/network_connection")
              .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

            @driver.get_network_connection

            assert_requested(:get, "#{SESSION}/network_connection", times: 1)
          end

          def test_get_performance_data_types
            stub_request(:post, "#{SESSION}/appium/performanceData/types")
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.get_performance_data_types

            assert_requested(:post, "#{SESSION}/appium/performanceData/types", times: 1)
          end

          def test_push_file
            stub_request(:post, "#{SESSION}/appium/device/push_file")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.push_file 'path/to/save/data', 'data'

            assert_requested(:post, "#{SESSION}/appium/device/push_file", times: 1)
          end

          def test_pull_file
            stub_request(:post, "#{SESSION}/appium/device/pull_file")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.pull_file 'path/to/save/data'

            assert_requested(:post, "#{SESSION}/appium/device/pull_file", times: 1)
          end

          def test_pull_folder
            stub_request(:post, "#{SESSION}/appium/device/pull_folder")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.pull_folder 'path/to/save/data'

            assert_requested(:post, "#{SESSION}/appium/device/pull_folder", times: 1)
          end

          def test_get_settings
            stub_request(:get, "#{SESSION}/appium/settings")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.get_settings

            assert_requested(:get, "#{SESSION}/appium/settings", times: 1)
          end

          def test_settings_get
            stub_request(:get, "#{SESSION}/appium/settings")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.settings.get

            assert_requested(:get, "#{SESSION}/appium/settings", times: 1)
          end

          def test_update_settings
            stub_request(:post, "#{SESSION}/appium/settings")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.update_settings({ sample: 'value' })

            assert_requested(:post, "#{SESSION}/appium/settings", times: 1)
          end

          def test_settings_update
            stub_request(:post, "#{SESSION}/appium/settings")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.settings.update(sample: 'value')

            assert_requested(:post, "#{SESSION}/appium/settings", times: 1)
          end

          def test_settings_update_equal
            stub_request(:post, "#{SESSION}/appium/settings")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.settings = { sample: 'value' }

            assert_requested(:post, "#{SESSION}/appium/settings", times: 1)
          end

          def test_start_activity
            stub_request(:post, "#{SESSION}/appium/device/start_activity")
              .with(body: { appPackage: 'package', appActivity: 'activity', intentAction: 'action.MAIN' }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)
            @driver.start_activity(app_activity: 'activity', app_package: 'package', intent_action: 'action.MAIN')

            assert_requested(:post, "#{SESSION}/appium/device/start_activity", times: 1)
          end

          def test_start_activity_with_wait
            stub_request(:post, "#{SESSION}/appium/device/start_activity")
              .with(body: { appPackage: 'package', appActivity: 'activity',
                            appWaitPackage: 'wait_package', appWaitActivity: 'wait_activity',
                            intentAction: 'action.MAIN', dontStopAppOnReset: true }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.start_activity(app_activity: 'activity', app_package: 'package',
                                   app_wait_package: 'wait_package', app_wait_activity: 'wait_activity',
                                   intent_action: 'action.MAIN', dont_stop_app_on_reset: true)

            assert_requested(:post, "#{SESSION}/appium/device/start_activity", times: 1)
          end

          def test_set_network_connection
            stub_request(:post, "#{SESSION}/network_connection")
              .with(body: { type: 1 }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.set_network_connection 1

            assert_requested(:post, "#{SESSION}/network_connection", times: 1)
          end

          def test_set_network_connection_key
            stub_request(:post, "#{SESSION}/network_connection")
              .with(body: { type: 6 }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.set_network_connection :all

            assert_requested(:post, "#{SESSION}/network_connection", times: 1)
          end

          def test_get_perfoemance_data
            stub_request(:post, "#{SESSION}/appium/getPerformanceData")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.get_performance_data(package_name: 'package_name', data_type: 'type')

            assert_requested(:post, "#{SESSION}/appium/getPerformanceData", times: 1)
          end

          def test_start_recording_screen_default
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: { timeLimit: '180' } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end

          def test_start_recording_screen_custom
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: { videoSize: '1280x1280', timeLimit: '60', bitRate: '5000000' } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen video_size: '1280x1280', time_limit: '60', bit_rate: '5000000'

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end

          def test_stop_recording_screen_default
            stub_request(:post, "#{SESSION}/appium/stop_recording_screen")
              .with(body: {}.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.stop_recording_screen

            assert_requested(:post, "#{SESSION}/appium/stop_recording_screen", times: 1)
          end

          def test_start_recording_screen_custom_bug_report
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: { videoSize: '1280x1280', timeLimit: '60', bugReport: true } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen video_size: '1280x1280', time_limit: '60', bug_report: true

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end

          def test_start_recording_screen_additional_options
            stub_request(:post, "#{SESSION}/appium/start_recording_screen")
              .with(body: { options: {
                remotePath: 'https://example.com', method: 'PUT',
                fileFieldName: 'file', formFields: [%w(email example@mail.com), { file: 'another data' }],
                headers: { 'x-custom-header' => 'xxxxx' },
                timeLimit: '180'
              } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.start_recording_screen remote_path: 'https://example.com', file_field_name: 'file',
                                           form_fields: [%w(email example@mail.com), { file: 'another data' }],
                                           headers: { 'x-custom-header': 'xxxxx' }

            assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
          end

          def test_stop_recording_screen_custom
            stub_request(:post, "#{SESSION}/appium/stop_recording_screen")
              .with(body: { options:
                                { remotePath: 'https://example.com', user: 'user name', pass: 'pass', method: 'PUT' } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

            @driver.stop_recording_screen(remote_path: 'https://example.com', user: 'user name', pass: 'pass')

            assert_requested(:post, "#{SESSION}/appium/stop_recording_screen", times: 1)
          end

          # emulator
          def test_send_sms
            stub_request(:post, "#{SESSION}/appium/device/send_sms")
              .with(body: { phoneNumber: '00000000000', message: 'test message' }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.send_sms phone_number: '00000000000', message: 'test message'

            assert_requested(:post, "#{SESSION}/appium/device/send_sms", times: 1)
          end

          def test_gsm_call
            stub_request(:post, "#{SESSION}/appium/device/gsm_call")
              .with(body: { phoneNumber: '00000000000', action: 'call' }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.gsm_call phone_number: '00000000000', action: :call

            assert_requested(:post, "#{SESSION}/appium/device/gsm_call", times: 1)
          end

          def test_gsm_signal
            stub_request(:post, "#{SESSION}/appium/device/gsm_signal")
              .with(body: { signalStrength: ::Appium::Core::Android::Device::Emulator::GSM_SIGNALS[:good],
                            signalStrengh: ::Appium::Core::Android::Device::Emulator::GSM_SIGNALS[:good] }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.gsm_signal :good

            assert_requested(:post, "#{SESSION}/appium/device/gsm_signal", times: 1)
          end

          def test_gsm_voice
            stub_request(:post, "#{SESSION}/appium/device/gsm_voice")
              .with(body: { state: 'on' }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.gsm_voice :on

            assert_requested(:post, "#{SESSION}/appium/device/gsm_voice", times: 1)
          end

          def test_network_speed
            stub_request(:post, "#{SESSION}/appium/device/network_speed")
              .with(body: { netspeed: 'gsm' }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.set_network_speed :gsm

            assert_requested(:post, "#{SESSION}/appium/device/network_speed", times: 1)
          end

          def test_set_power_capacity
            stub_request(:post, "#{SESSION}/appium/device/power_capacity")
              .with(body: { percent: 10 }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.set_power_capacity 10

            assert_requested(:post, "#{SESSION}/appium/device/power_capacity", times: 1)
          end

          def test_power_ac
            stub_request(:post, "#{SESSION}/appium/device/power_ac")
              .with(body: { state: 'on' }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.set_power_ac :on

            assert_requested(:post, "#{SESSION}/appium/device/power_ac", times: 1)
          end

          # toggles
          def test_toggle_wifi
            stub_request(:post, "#{SESSION}/appium/device/toggle_wifi")
              .with(body: '{}')
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.toggle_wifi

            assert_requested(:post, "#{SESSION}/appium/device/toggle_wifi", times: 1)
          end

          def test_toggle_data
            stub_request(:post, "#{SESSION}/appium/device/toggle_data")
              .with(body: '{}')
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.toggle_data

            assert_requested(:post, "#{SESSION}/appium/device/toggle_data", times: 1)
          end

          def test_toggle_location_services
            stub_request(:post, "#{SESSION}/appium/device/toggle_location_services")
              .with(body: '{}')
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.toggle_location_services

            assert_requested(:post, "#{SESSION}/appium/device/toggle_location_services", times: 1)
          end

          def test_get_battery_info
            skip('Only uiautomator2 has this method') unless @core.automation_name == :uiautomator2

            stub_request(:post, "#{SESSION}/execute/sync")
              .with(body: { script: 'mobile: batteryInfo', args: [{}] }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: { state: 5, level: 0.5 } }.to_json)

            info = @driver.battery_info

            assert_requested(:post, "#{SESSION}/execute/sync", times: 1)
            assert_equal :full, info[:state]
            assert_equal 0.5, info[:level]
          end

          def test_search_element_child_element
            stub_request(:post, "#{SESSION}/element")
              .with(body: { using: 'id', value: 'example' }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: { ELEMENT: 'element_id_parent' },
                                                               sessionId: SESSION, status: 0 }.to_json)
            stub_request(:post, "#{SESSION}/element/element_id_parent/element")
              .with(body: { using: 'id', value: 'example2' }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: { ELEMENT: 'element_id_children' },
                                                               sessionId: SESSION, status: 0 }.to_json)

            @driver.find_element(:id, 'example').find_element(:id, 'example2')

            assert_requested(:post, "#{SESSION}/element", times: 1)
            assert_requested(:post, "#{SESSION}/element/element_id_parent/element", times: 1)
          end

          def test_chromium_send_command
            stub_request(:post, "#{SESSION}/goog/cdp/execute")
              .with(body: { cmd: 'Page.captureScreenshot', params: { quality: 1, format: 'jpeg' } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: { data: '/9j/4AAQSkZJRgABAQAAAQABAAD' } }.to_json)

            r = @driver.execute_cdp 'Page.captureScreenshot', quality: 1, format: 'jpeg'

            assert_requested(:post, "#{SESSION}/goog/cdp/execute", times: 1)
            assert_equal '/9j/4AAQSkZJRgABAQAAAQABAAD', r['data']
          end

          def test_chromium_send_command_no_param
            stub_request(:post, "#{SESSION}/goog/cdp/execute")
              .with(body: { cmd: 'Page.getResourceTree', params: {} }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: { frameTree: { childFrames: [] } } }.to_json)

            r = @driver.execute_cdp 'Page.getResourceTree'

            assert_requested(:post, "#{SESSION}/goog/cdp/execute", times: 1)
            assert_equal({ 'childFrames' => [] }, r['frameTree'])
          end
        end # class CommandsTest
      end # module W3C
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
