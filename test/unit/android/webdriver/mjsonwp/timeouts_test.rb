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

# $ rake test:unit TEST=test/unit/android/webdriver/mjsonwp/commands_test.rb
class AppiumLibCoreTest
  module Android
    module WebDriver
      module MJSONWP
        class TimeoutsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session
          end

          def test_implicit_wait
            stub_request(:post, "#{SESSION}/timeouts/implicit_wait")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.manage.timeouts.implicit_wait = 30

            assert_requested(:post, "#{SESSION}/timeouts/implicit_wait", times: 2)
          end
        end # class TimeoutsTest
      end # module MJSONWP
    end # module WebDriver
  end # module Android
end # class AppiumLibCoreTest
