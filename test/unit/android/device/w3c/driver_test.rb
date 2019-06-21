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
        class DriverTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_batch_no_timeout
            script = <<~SCRIPT
              const timeouts = await driver.getTimeouts();
              const status = await driver.status();
              return [timeouts, status];
            SCRIPT

            stub_request(:post, "#{SESSION}/appium/execute_driver")
              .with(body: { script: script, type: 'webdriverio' }.to_json)
              .to_return(headers: HEADER, status: 200, body: {
                value: { result: { command: 250, implicit: 0 }, logs: { log: [], warn: [], error: [] } }
              }.to_json)

            result = @driver.execute_driver(script: script, type: 'webdriverio')

            assert_requested(:post, "#{SESSION}/appium/execute_driver", times: 1)
            assert_equal({ command: 250, implicit: 0 }, JSON.parse(result['result']))
            assert_equal({ log: [], warn: [], error: [] }, JSON.parse(result['logs']))
          end

          def test_batch
            script = <<~SCRIPT
              const timeouts = await driver.getTimeouts();
              const status = await driver.status();
              return [timeouts, status];
            SCRIPT

            stub_request(:post, "#{SESSION}/appium/execute_driver")
              .with(body: { script: script, type: 'webdriverio', timeout: 1000 }.to_json)
              .to_return(headers: HEADER, status: 200, body: {
                value: { result: { command: 250, implicit: 0 }, logs: { log: [], warn: [], error: [] } }
              }.to_json)

            result = @driver.execute_driver(script: script, type: 'webdriverio', timeout: 1000)

            assert_requested(:post, "#{SESSION}/appium/execute_driver", times: 1)
            assert_equal({ command: 250, implicit: 0 }, JSON.parse(result['result']))
            assert_equal({ log: [], warn: [], error: [] }, JSON.parse(result['logs']))
          end
        end # class DeviceLockTest
      end # module W3C
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
