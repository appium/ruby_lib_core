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
        class ImeActionsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session
          end

          def test_ime_activate
            stub_request(:post, "#{SESSION}/ime/activate")
              .with(body: { engine: 'engine name' }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: {} }.to_json)

            @driver.ime_activate 'engine name'

            assert_requested(:post, "#{SESSION}/ime/activate", times: 1)
          end

          def test_activate_ime
            stub_request(:post, "#{SESSION}/ime/activate")
              .with(body: { engine: 'engine name' }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: {} }.to_json)

            @driver.ime.activate 'engine name'

            assert_requested(:post, "#{SESSION}/ime/activate", times: 1)
          end

          def test_ime_available_engines
            stub_request(:get, "#{SESSION}/ime/available_engines")
              .to_return(headers: HEADER, status: 200, body: { value: %w(ime1 ime2) }.to_json)

            imes = @driver.ime_available_engines

            assert_requested(:get, "#{SESSION}/ime/available_engines", times: 1)
            assert_equal imes[0], 'ime1'
          end

          def test_available_engines_ime
            stub_request(:get, "#{SESSION}/ime/available_engines")
              .to_return(headers: HEADER, status: 200, body: { value: %w(ime1 ime2) }.to_json)

            imes = @driver.ime.available_engines

            assert_requested(:get, "#{SESSION}/ime/available_engines", times: 1)
            assert_equal imes[0], 'ime1'
          end

          def test_ime_active_engine
            stub_request(:get, "#{SESSION}/ime/active_engine")
              .to_return(headers: HEADER, status: 200, body: { value: 'ime' }.to_json)

            ime = @driver.ime_active_engine

            assert_requested(:get, "#{SESSION}/ime/active_engine", times: 1)
            assert_equal ime, 'ime'
          end

          def test_active_engine_ime
            stub_request(:get, "#{SESSION}/ime/active_engine")
              .to_return(headers: HEADER, status: 200, body: { value: 'ime' }.to_json)

            ime = @driver.ime.active_engine

            assert_requested(:get, "#{SESSION}/ime/active_engine", times: 1)
            assert_equal ime, 'ime'
          end

          def test_ime_activated
            stub_request(:get, "#{SESSION}/ime/activated")
              .to_return(headers: HEADER, status: 200, body: { value: 'true' }.to_json)

            @driver.ime_activated

            assert_requested(:get, "#{SESSION}/ime/activated", times: 1)
          end

          def test_activated_ime
            stub_request(:get, "#{SESSION}/ime/activated")
              .to_return(headers: HEADER, status: 200, body: { value: 'true' }.to_json)

            @driver.ime.activated?

            assert_requested(:get, "#{SESSION}/ime/activated", times: 1)
          end

          def test_ime_deactivate
            stub_request(:post, "#{SESSION}/ime/deactivate")
              .with(body: {}.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: 'true' }.to_json)

            @driver.ime_deactivate

            assert_requested(:post, "#{SESSION}/ime/deactivate", times: 1)
          end

          def test_deactivate_ime
            stub_request(:post, "#{SESSION}/ime/deactivate")
              .with(body: {}.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: 'true' }.to_json)

            @driver.ime.deactivate

            assert_requested(:post, "#{SESSION}/ime/deactivate", times: 1)
          end
        end # class ImeActionsTest
      end # module MJSONWP
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
