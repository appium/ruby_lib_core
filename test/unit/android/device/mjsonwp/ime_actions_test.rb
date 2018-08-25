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

          def test_ime_available_engines
            stub_request(:get, "#{SESSION}/ime/available_engines")
              .to_return(headers: HEADER, status: 200, body: { value: %w(ime1 ime2) }.to_json)

            imes = @driver.ime_available_engines

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

          def test_ime_activated
            stub_request(:get, "#{SESSION}/ime/activated")
              .to_return(headers: HEADER, status: 200, body: { value: 'true' }.to_json)

            @driver.ime_activated

            assert_requested(:get, "#{SESSION}/ime/activated", times: 1)
          end

          def test_ime_deactivate
            stub_request(:post, "#{SESSION}/ime/deactivate")
              .with(body: {}.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: 'true' }.to_json)

            @driver.ime_deactivate

            assert_requested(:post, "#{SESSION}/ime/deactivate", times: 1)
          end
        end # class ImeActionsTest
      end # module MJSONWP
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
