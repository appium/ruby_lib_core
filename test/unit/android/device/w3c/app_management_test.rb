require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/android/device/w3c/commands_test.rb
class AppiumLibCoreTest
  module Android
    module Device
      module W3C
        class AppManagementTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(self, Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_launch_app
            stub_request(:post, "#{SESSION}/appium/app/launch")
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.launch_app

            assert_requested(:post, "#{SESSION}/appium/app/launch", times: 1)
          end

          def test_close_app
            stub_request(:post, "#{SESSION}/appium/app/close")
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.close_app

            assert_requested(:post, "#{SESSION}/appium/app/close", times: 1)
          end

          def test_reset
            stub_request(:post, "#{SESSION}/appium/app/reset")
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.reset

            assert_requested(:post, "#{SESSION}/appium/app/reset", times: 1)
          end

          def test_app_strings
            stub_request(:post, "#{SESSION}/appium/app/strings")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.app_strings

            assert_requested(:post, "#{SESSION}/appium/app/strings", times: 1)
          end

          def test_background_app
            stub_request(:post, "#{SESSION}/appium/app/background")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.background_app 0

            assert_requested(:post, "#{SESSION}/appium/app/background", times: 1)
          end

          def test_end_coverage
            stub_request(:post, "#{SESSION}/appium/app/end_test_coverage")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.end_coverage 'path/to', 'intent'

            assert_requested(:post, "#{SESSION}/appium/app/end_test_coverage", times: 1)
          end

          def test_terminate_app
            stub_request(:post, "#{SESSION}/appium/device/terminate_app")
              .to_return(headers: HEADER, status: 200, body: { value: true }.to_json)

            @driver.terminate_app 'com.app.id'

            assert_requested(:post, "#{SESSION}/appium/device/terminate_app", times: 1)
          end

          def test_terminate_app_with_param
            stub_request(:post, "#{SESSION}/appium/device/terminate_app")
              .with(body: { appId: 'com.app.id', options: { timeout: 20_000 } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: true }.to_json)

            @driver.terminate_app 'com.app.id', timeout: 20_000

            assert_requested(:post, "#{SESSION}/appium/device/terminate_app", times: 1)
          end

          def test_activate_app
            stub_request(:post, "#{SESSION}/appium/device/activate_app")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.activate_app 'com.app.id'

            assert_requested(:post, "#{SESSION}/appium/device/activate_app", times: 1)
          end

          def test_app_state
            stub_request(:post, "#{SESSION}/appium/device/app_state")
              .to_return(headers: HEADER, status: 200, body: { value: 4 }.to_json)

            state = @driver.app_state 'com.app.id'

            assert_requested(:post, "#{SESSION}/appium/device/app_state", times: 1)
            assert_equal :running_in_foreground, state
          end

          def test_install_app
            stub_request(:post, "#{SESSION}/appium/device/install_app")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.install_app 'app_path'

            assert_requested(:post, "#{SESSION}/appium/device/install_app", times: 1)
          end

          def test_install_app_with_params
            stub_request(:post, "#{SESSION}/appium/device/install_app")
              .with(body: { appPath: 'app_path',
                            options: {
                              replace: true,
                              timeout: 20_000,
                              allowTestPackages: true,
                              useSdcard: false,
                              grantPermissions: false
                            } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.install_app 'app_path',
                                replace: true,
                                timeout: 20_000,
                                allow_test_packages: true,
                                use_sdcard: false,
                                grant_permissions: false

            assert_requested(:post, "#{SESSION}/appium/device/install_app", times: 1)
          end

          def test_remove_app
            stub_request(:post, "#{SESSION}/appium/device/remove_app")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.remove_app 'com.app.id'

            assert_requested(:post, "#{SESSION}/appium/device/remove_app", times: 1)
          end

          def test_remove_app_with_param
            stub_request(:post, "#{SESSION}/appium/device/remove_app")
              .with(body: { appId: 'com.app.id', options: { keepData: false, timeout: 20_000 } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.remove_app 'com.app.id', keep_data: false, timeout: 20_000

            assert_requested(:post, "#{SESSION}/appium/device/remove_app", times: 1)
          end

          def test_app_installed?
            stub_request(:post, "#{SESSION}/appium/device/app_installed")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.app_installed? 'com.app.id'

            assert_requested(:post, "#{SESSION}/appium/device/app_installed", times: 1)
          end
        end # class AppManagementTest
      end # module W3C
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
