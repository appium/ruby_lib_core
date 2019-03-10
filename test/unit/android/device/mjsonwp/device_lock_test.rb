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
require 'base64'

# $ rake test:unit TEST=test/unit/android/device/mjsonwp/commands_test.rb
class AppiumLibCoreTest
  module Android
    module Device
      module MJSONWP
        class DeviceLockTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session
          end

          def test_device_locked?
            stub_request(:post, "#{SESSION}/appium/device/is_locked")
              .to_return(headers: HEADER, status: 200, body: { value: 'true' }.to_json)

            @driver.device_locked?

            assert_requested(:post, "#{SESSION}/appium/device/is_locked", times: 1)
          end

          def test_locked?
            stub_request(:post, "#{SESSION}/appium/device/is_locked")
              .to_return(headers: HEADER, status: 200, body: { value: 'true' }.to_json)

            @driver.locked?

            assert_requested(:post, "#{SESSION}/appium/device/is_locked", times: 1)
          end

          def test_unlock
            stub_request(:post, "#{SESSION}/appium/device/unlock")
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.unlock

            assert_requested(:post, "#{SESSION}/appium/device/unlock", times: 1)
          end

          def test_lock
            stub_request(:post, "#{SESSION}/appium/device/lock")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.lock 5

            assert_requested(:post, "#{SESSION}/appium/device/lock", times: 1)
          end
        end # class DeviceLockTest
      end # module MJSONWP
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
