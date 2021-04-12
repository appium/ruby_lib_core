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
        class ScreenshotTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_save_screenshot
            stub_request(:get, "#{SESSION}/screenshot")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.save_screenshot 'sample.png'

            assert_requested(:get, "#{SESSION}/screenshot", times: 1)
          end

          def test_save_screenshot_error
            stub_request(:get, "#{SESSION}/screenshot")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.save_screenshot 'sample.jpg'

            assert_requested(:get, "#{SESSION}/screenshot", times: 1)
          end

          def test_screenshot_as
            stub_request(:get, "#{SESSION}/screenshot")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.screenshot_as :base64

            assert_requested(:get, "#{SESSION}/screenshot", times: 1)
          end

          def test_screenshot_as_raise_error
            stub_request(:get, "#{SESSION}/screenshot")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            assert_raises ::Appium::Core::Error::UnsupportedOperationError do
              @driver.screenshot_as :unsupported
            end
          end

          def test_take_element_screenshot
            stub_request(:get, "#{SESSION}/element/id/screenshot")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.take_element_screenshot ::Appium::Core::Element.new(@driver.send(:bridge), 'id'), 'sample.png'

            assert_requested(:get, "#{SESSION}/element/id/screenshot", times: 1)
          end

          def test_take_element_screenshot_wrong_ext
            stub_request(:get, "#{SESSION}/element/id/screenshot")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.take_element_screenshot ::Appium::Core::Element.new(@driver.send(:bridge), 'id'), 'sample.jpg'

            assert_requested(:get, "#{SESSION}/element/id/screenshot", times: 1)
          end

          def test_element_screenshot_as_base64
            stub_request(:get, "#{SESSION}/element/id/screenshot")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.element_screenshot_as ::Appium::Core::Element.new(@driver.send(:bridge), 'id'), :base64

            assert_requested(:get, "#{SESSION}/element/id/screenshot", times: 1)
          end

          def test_element_screenshot_as_base64_raise_error
            stub_request(:get, "#{SESSION}/element/id/screenshot")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            assert_raises ::Appium::Core::Error::UnsupportedOperationError do
              @driver.element_screenshot_as ::Appium::Core::Element.new(@driver.send(:bridge), 'id'), :unsupported
            end
          end

          def test_save_viewport_screenshot
            stub_request(:post, "#{SESSION}/execute/sync")
              .with(body: { script: 'mobile: viewportScreenshot', args: [] }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            result = @driver.save_viewport_screenshot 'test.png'

            assert_requested(:post, "#{SESSION}/execute/sync", times: 1)

            assert File.exist? result.path
            File.delete result.path
          end

          def test_save_viewport_screenshot_wrong_ext
            stub_request(:post, "#{SESSION}/execute/sync")
              .with(body: { script: 'mobile: viewportScreenshot', args: [] }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            result = @driver.save_viewport_screenshot 'test.jpg'

            assert_requested(:post, "#{SESSION}/execute/sync", times: 1)
            File.delete result
          end
        end # class ScreenshotTest
      end # module W3C
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
