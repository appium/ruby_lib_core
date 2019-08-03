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

# $ rake test:unit TEST=test/unit/ios/device/w3c/app_management_test.rb
class AppiumLibCoreTest
  module IOS
    module Device
      module W3C
        class AppManagementTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.ios)
            @driver ||= ios_mock_create_session_w3c
          end

          def test_activate_app
            stub_request(:post, "#{SESSION}/appium/device/activate_app")
              .with(body: { bundleId: 'com.app.id' }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.activate_app 'com.app.id'
            assert_requested(:post, "#{SESSION}/appium/device/activate_app", times: 1)
          end

          def test_activate_app_with_env
            skip unless @core.automation_name == :xcuitest

              stub_request(:post, "#{SESSION}/appium/device/activate_app")
              .with(body: { bundleId: 'com.app.id', options: { environment: { IOS_TESTING: 'happy testing' } } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.activate_app 'com.app.id', environment: { IOS_TESTING: 'happy testing' }
            assert_requested(:post, "#{SESSION}/appium/device/activate_app", times: 1)
          end

          def test_activate_app_with_both
            skip unless @core.automation_name == :xcuitest

            stub_request(:post, "#{SESSION}/appium/device/activate_app")
              .with(body: { bundleId: 'com.app.id', options: { arguments: %w(1 2 3),
                                                               environment: { IOS_TESTING: 'happy testing' } } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.activate_app 'com.app.id', arguments: %w(1 2 3), environment: { IOS_TESTING: 'happy testing' }

            assert_requested(:post, "#{SESSION}/appium/device/activate_app", times: 1)
          end
        end # class AppManagementTest
      end # module W3C
    end # module Device
  end # module IOS
end # class AppiumLibCoreTest
