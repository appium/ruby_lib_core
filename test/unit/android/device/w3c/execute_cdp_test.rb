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
        class ExecuteCDPAndroidTest < Minitest::Test
          include AppiumLibCoreTest::Mock
          def test_execute_cdp
            @core = ::Appium::Core.for(Caps.android)
            @driver = android_mock_create_session_w3c

            stub_request(:post, "#{SESSION}/goog/cdp/execute")
              .with(body: { cmd: 'Emulation.setTimezoneOverride', params: { timezoneId: 'Asia/Tokyo' } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: {} }.to_json)

            @driver.execute_cdp 'Emulation.setTimezoneOverride', 'timezoneId': 'Asia/Tokyo'

            assert_requested(:post, "#{SESSION}/goog/cdp/execute", times: 1)
          end
        end

        class ExecuteCDPChromeTest < Minitest::Test
          include AppiumLibCoreTest::Mock
          def test_execute_cdp_chrome
            @core = ::Appium::Core.for(Caps.android)
            @driver = android_chrome_mock_create_session_w3c

            stub_request(:post, "#{SESSION}/goog/cdp/execute")
              .with(body: { cmd: 'Emulation.setTimezoneOverride', params: { timezoneId: 'Asia/Tokyo' } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: {} }.to_json)

            @driver.execute_cdp 'Emulation.setTimezoneOverride', 'timezoneId': 'Asia/Tokyo'

            assert_requested(:post, "#{SESSION}/goog/cdp/execute", times: 1)
          end
        end
      end # module W3C
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
