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

# $ rake test:unit TEST=test/unit/android/webdriver/w3c/alerts_test.rb
class AppiumLibCoreTest
  module Android
    module WebDriver
      module W3C
        class AlertsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_accept_alert
            stub_request(:get, "#{SESSION}/alert/text")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)
            stub_request(:post, "#{SESSION}/alert/accept")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.switch_to.alert.accept

            assert_requested(:post, "#{SESSION}/alert/accept", times: 1)
            assert_requested(:get, "#{SESSION}/alert/text", times: 1)
          end

          def test_dismiss_alert
            stub_request(:get, "#{SESSION}/alert/text")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)
            stub_request(:post, "#{SESSION}/alert/dismiss")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.switch_to.alert.dismiss

            assert_requested(:post, "#{SESSION}/alert/dismiss", times: 1)
            assert_requested(:get, "#{SESSION}/alert/text", times: 1)
          end
        end # class AlertsTest
      end # module W3C
    end # module WebDriver
  end # module Android
end # class AppiumLibCoreTest
