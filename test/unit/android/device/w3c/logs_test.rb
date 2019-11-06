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

# $ rake test:unit TEST=test/unit/android/device/w3c/logs_test.rb
class AppiumLibCoreTest
  module Android
    module Device
      module W3C
        class LogsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_logs
            stub_request(:post, "#{SESSION}/appium/log_event")
              .with(body: { vendor: 'appium', event: 'customEvent' }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.logs.event vendor: 'appium', event: 'customEvent'

            assert_requested(:post, "#{SESSION}/appium/log_event", times: 1)
          end

          def test_log_events
            stub_request(:post, "#{SESSION}/appium/events")
              .with(body: {}.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.logs.events

            assert_requested(:post, "#{SESSION}/appium/events", times: 1)
          end

          def test_log_events_with_type
            stub_request(:post, "#{SESSION}/appium/events")
              .with(body: { type: 'commands' }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.logs.events('commands')

            assert_requested(:post, "#{SESSION}/appium/events", times: 1)
          end
        end # class Logs
      end # module W3C
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
