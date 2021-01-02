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

# $ rake test:unit TEST=test/unit/common/element_test.rb
class AppiumLibCoreTest
  class ElementTest < Minitest::Test
    include AppiumLibCoreTest::Mock

    def setup
      @core ||= ::Appium::Core.for(Caps.android)
      @driver ||= android_mock_create_session_w3c
    end

    def test_method_missing
      stub_request(:get, "#{SESSION}/element/id/attribute/content-desc")
        .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

      e = ::Selenium::WebDriver::Element.new(@driver.send(:bridge), 'id')
      e.content_desc

      assert_requested(:get, "#{SESSION}/element/id/attribute/content-desc", times: 1)
    end

    def test_location_rel
      stub_request(:get, "#{SESSION}/element/id/rect")
        .to_return(headers: HEADER, status: 200, body: { value: {
          x: '10', y: '10', width: '100', height: '200'
        } }.to_json)
      stub_request(:get, "#{SESSION}/window/rect")
        .to_return(headers: HEADER, status: 200, body: { value: {
          x: '0', y: '0', width: '375', height: '667'
        } }.to_json)

      e = ::Selenium::WebDriver::Element.new(@driver.send(:bridge), 'id')
      location = e.location_rel @driver

      assert_requested(:get, "#{SESSION}/element/id/rect", times: 1)
      assert_requested(:get, "#{SESSION}/window/rect", times: 1)
      assert_equal '60.0 / 375.0', location.x
      assert_equal '110.0 / 667.0', location.y
    end

    def test_immediate_value
      stub_request(:post, "#{SESSION}/appium/element/id/value")
        .with(body: { value: %w(h e l l o) }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

      e = ::Selenium::WebDriver::Element.new(@driver.send(:bridge), 'id')
      e.immediate_value 'hello'

      assert_requested(:post, "#{SESSION}/appium/element/id/value", times: 1)
    end

    def test_replace
      stub_request(:post, "#{SESSION}/appium/element/id/replace_value")
        .with(body: { value: %w(h e l l o) }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

      e = ::Selenium::WebDriver::Element.new(@driver.send(:bridge), 'id')
      e.replace_value 'hello'

      assert_requested(:post, "#{SESSION}/appium/element/id/replace_value", times: 1)
    end

    def test_element_screenshot_as
      stub_request(:get, "#{SESSION}/element/id/screenshot")
        .to_return(headers: HEADER, status: 200,
                   body: { value: 'iVBORw0KGgoAAAANSUhEUgAABDgAAAB+CAIAAABOPDa6AAAAAX' }.to_json)

      e = ::Selenium::WebDriver::Element.new(@driver.send(:bridge), 'id')
      assert_equal 'iVBORw0KGgoAAAANSUhEUgAABDgAAAB+CAIAAABOPDa6AAAAAX', e.screenshot_as(:base64)
      assert_requested(:get, "#{SESSION}/element/id/screenshot", times: 1)
    end
  end
end
