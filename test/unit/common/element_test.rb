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

      e = ::Appium::Core::Element.new(@driver.send(:bridge), 'id')
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

      e = ::Appium::Core::Element.new(@driver.send(:bridge), 'id')
      location = e.location_rel @driver

      assert_requested(:get, "#{SESSION}/element/id/rect", times: 1)
      assert_requested(:get, "#{SESSION}/window/rect", times: 1)
      assert_equal '60.0 / 375.0', location.x
      assert_equal '110.0 / 667.0', location.y
    end

    def test_element_screenshot_as
      stub_request(:get, "#{SESSION}/element/id/screenshot")
        .to_return(headers: HEADER, status: 200,
                   body: { value: 'iVBORw0KGgoAAAANSUhEUgAABDgAAAB+CAIAAABOPDa6AAAAAX' }.to_json)

      e = ::Appium::Core::Element.new(@driver.send(:bridge), 'id')
      assert_equal 'iVBORw0KGgoAAAANSUhEUgAABDgAAAB+CAIAAABOPDa6AAAAAX', e.screenshot_as(:base64)
      assert_requested(:get, "#{SESSION}/element/id/screenshot", times: 1)
    end

    def test_element_screenshot
      stub_request(:get, "#{SESSION}/element/id/screenshot")
        .to_return(headers: HEADER, status: 200,
                   body: { value: 'iVBORw0KGgoAAAANSUhEUgAABDgAAAB+CAIAAABOPDa6AAAAAX' }.to_json)

      e = ::Appium::Core::Element.new(@driver.send(:bridge), 'id')
      assert_equal 'iVBORw0KGgoAAAANSUhEUgAABDgAAAB+CAIAAABOPDa6AAAAAX', e.screenshot
      assert_requested(:get, "#{SESSION}/element/id/screenshot", times: 1)
    end

    def test_element_cached_attributes
      stub_request(:post, "#{SESSION}/element")
        .with(body: { using: 'id', value: 'example' }.to_json)
        .to_return(headers: HEADER, status: 200, body: {
          value: {
            ::Appium::Core::Element::ELEMENT_KEY => 'element_id_1',
            'ELEMENT' => 'element_id_1',
            'name' => 'android.widget.TextView',
            'text' => 'Hello World',
            'enabled' => true,
            'displayed' => false,
            'selected' => false,
            'attribute/content-desc' => 'greeting_label',
            'rect' => { 'x' => 10, 'y' => 20, 'width' => 100, 'height' => 50 }
          },
          sessionId: SESSION,
          status: 0
        }.to_json)

      e = @driver.find_element id: 'example'
      assert_equal 'element_id_1', e.id
      assert_equal 'android.widget.TextView', e.cached.name
      assert_equal 'android.widget.TextView', e.cached.tag_name
      assert_equal 'Hello World', e.cached.text
      assert_equal true, e.cached.enabled
      assert_equal true, e.cached.enabled?
      assert_equal false, e.cached.displayed
      assert_equal false, e.cached.displayed?
      assert_equal false, e.cached.selected?
      assert_equal 'greeting_label', e.cached.content_desc
      assert_equal 'greeting_label', e.cached.attribute('content-desc')
      assert_equal 'greeting_label', e.cached['content-desc']
      assert_equal ::Selenium::WebDriver::Rectangle.new(10, 20, 100, 50), e.cached.rect
      assert_equal ::Selenium::WebDriver::Point.new(10, 20), e.cached.location
      assert_equal ::Selenium::WebDriver::Dimension.new(100, 50), e.cached.size
      assert_nil e.cached.non_existent_attribute
      assert_nil e.cached.attributes[::Appium::Core::Element::ELEMENT_KEY]
      assert_nil e.cached.attributes['ELEMENT']
    end

    def test_elements_cached_attributes
      stub_request(:post, "#{SESSION}/elements")
        .with(body: { using: 'id', value: 'example' }.to_json)
        .to_return(headers: HEADER, status: 200, body: {
          value: [
            {
              ::Appium::Core::Element::ELEMENT_KEY => 'element_id_1',
              'text' => 'First',
              'attribute/resource-id' => 'com.example:id/first'
            },
            {
              ::Appium::Core::Element::ELEMENT_KEY => 'element_id_2',
              'text' => 'Second',
              'attribute/resource-id' => 'com.example:id/second'
            }
          ],
          sessionId: SESSION,
          status: 0
        }.to_json)

      els = @driver.find_elements id: 'example'
      assert_equal 2, els.length
      assert_equal 'First', els[0].cached.text
      assert_equal 'com.example:id/first', els[0].cached.resource_id
      assert_equal 'Second', els[1].cached.text
      assert_equal 'com.example:id/second', els[1].cached.resource_id
    end
  end
end
