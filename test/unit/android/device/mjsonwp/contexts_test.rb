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
        class ContextsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session
          end

          def test_current_context
            stub_request(:get, "#{SESSION}/context")
              .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

            @driver.current_context

            assert_requested(:get, "#{SESSION}/context", times: 1)
          end

          def test_available_contexts
            stub_request(:get, "#{SESSION}/contexts")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.available_contexts

            assert_requested(:get, "#{SESSION}/contexts", times: 1)
          end

          def test_set_context
            stub_request(:post, "#{SESSION}/context")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.set_context 'NATIVE_APP'

            assert_requested(:post, "#{SESSION}/context", times: 1)
          end
        end # class ContextsTest
      end # module MJSONWP
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
