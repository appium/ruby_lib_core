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

class AppiumLibCoreTest
  class ElementCacheTest < Minitest::Test
    include AppiumLibCoreTest::Mock

    def setup
      @core = Appium::Core.for(Caps.android)
      @driver = android_mock_create_session_w3c
    end

    def test_snapshot_and_normal_operation
      stub_value(:post, '/element', response)
      e = @driver.find_element(id: 'example')
      assert_equal 'original', e.cached.text
      assert_equal false, e.cached.enabled?
      assert_equal 'label', e.cached.content_desc
      assert_nil e.cached['missing']
      refute e.cached.respond_to?(:find_element)
      assert_raises(NoMethodError) { e.cached.find_element(id: 'x') }
      assert_equal({ Appium::Core::Element::ELEMENT_KEY => 'id' }, e.as_json)
      stub_value(:get, '/element/id/text', 'updated')
      assert_equal 'updated', e.text
      assert_equal 'original', e.cached.text
      assert_requested(:get, "#{SESSION}/element/id/text", times: 1)
      assert_requested(:post, "#{SESSION}/element", times: 1)
    end

    def test_find_contexts
      parent = Appium::Core::Element.new(@driver.bridge, 'parent')
      shadow = Selenium::WebDriver::ShadowRoot.new(@driver.bridge, 'shadow')
      [[@driver, ''], [parent, '/element/parent'], [shadow, '/shadow/shadow']].each do |context, prefix|
        stub_value(:post, "#{prefix}/element", response)
        stub_value(:post, "#{prefix}/elements", [response('one', 'first'), response('two', 'second')])
        assert_equal 'original', context.find_element(id: 'example').cached.text
        es = context.find_elements(id: 'example')
        assert_equal %w(one two), es.map(&:id)
        assert_equal(%w(first second), es.map { |e| e.cached.text })
      end
    end

    def test_active_script_and_conversion
      stub_value(:get, '/element/active', response)
      assert_equal 'original', @driver.switch_to.active_element.cached.text
      assert_equal 'original', @driver.bridge.switch_to_active_element.cached.text
      assert_equal 'original', @driver.convert_to_element(response).cached.text
      stub_value(:post, '/execute/sync', [response, { 'text' => 'plain' }, { Selenium::WebDriver::ShadowRoot::ROOT_KEY => 's' }])
      values = @driver.execute_script('return results')
      assert_equal 'original', values[0].cached.text
      assert_equal({ 'text' => 'plain' }, values[1])
      assert_instance_of Selenium::WebDriver::ShadowRoot, values[2]
    end

    def test_listener
      bridge = Appium::Support::EventFiringBridge.new(@driver.bridge, Selenium::WebDriver::Support::AbstractEventListener.new)
      stub_value(:post, '/element', response)
      stub_value(:post, '/elements', [response])
      e = bridge.find_element_by(:id, 'example')
      assert_equal 'original', e.cached.text
      assert_equal 'original', bridge.find_elements_by(:id, 'example').first.cached.text
      stub_value(:post, '/element/id/click', nil)
      e.click
      assert_requested(:post, "#{SESSION}/element/id/click", times: 1)
    end

    def test_compact_and_legacy
      [Appium::Core::Element::ELEMENT_KEY, 'ELEMENT'].each do |key|
        stub_value(:post, '/element', { key => 'id' })
        e = @driver.find_element(id: 'example')
        assert_equal 'id', e.id
        assert_empty e.cached.attributes
      end
    end

    def test_standard_boolean_fields_match_element_api
      %w(enabled displayed selected).each do |name|
        { 'true' => true, 'false' => false, true => true, false => false }.each do |raw, expected|
          stub_value(:post, '/element', response.merge(name => raw))
          stub_value(:get, "/element/id/#{name}", expected)
          element = @driver.find_element(id: 'example')
          assert_equal element.public_send("#{name}?"), element.cached.public_send("#{name}?")
          assert_equal expected, element.cached.public_send(name)
          assert_equal expected, element.cached[name]
          assert_equal expected, element.cached.attribute(name.to_sym)
          assert_equal raw, element.cached.attributes[name]
        end
      end
    end

    def test_geometry_and_tag_name_match_element_api
      rect = { 'x' => 10, 'y' => 20, 'width' => 100, 'height' => 50 }
      stub_value(:post, '/element', response.merge('rect' => rect, 'name' => 'android.widget.Button'))
      stub_value(:get, '/element/id/rect', rect)
      stub_value(:get, '/element/id/name', 'android.widget.Button')
      element = @driver.find_element(id: 'example')
      assert_equal element.rect, element.cached.rect
      assert_equal element.location, element.cached.location
      assert_equal element.size, element.cached.size
      assert_equal element.tag_name, element.cached.tag_name
      assert_equal element.cached.rect, element.cached['rect']
      assert_equal rect, element.cached.attributes['rect']
      assert_requested(:get, "#{SESSION}/element/id/rect", times: 3)
      assert_requested(:get, "#{SESSION}/element/id/name", times: 1)
    end

    def test_missing_standard_fields_are_not_false
      cache = Appium::Core::Element::Cache.new
      [:enabled?, :displayed?, :selected?, :rect, :location, :size, :tag_name].each do |name|
        assert_nil cache.public_send(name)
      end
    end

    def test_arbitrary_attributes_keep_server_types
      cache = Appium::Core::Element::Cache.new('attribute/custom' => 'false', 'attribute/enabled' => 'true')
      assert_equal 'false', cache.custom
      assert_equal 'false', cache['custom']
      assert_equal 'true', cache['attribute/enabled']
      assert_equal true, cache.enabled?
      assert_equal true, cache['enabled']
    end

    def test_custom_attribute_preserves_json_null_and_string_null
      [nil, 'null'].each do |value|
        stub_value(:post, '/element', response.merge('attribute/content-desc' => value))
        cache = @driver.find_element(id: 'example').cached
        assert cache.attributes.key?('attribute/content-desc')

        if value.nil?
          assert_nil cache.attributes['attribute/content-desc']
          assert_nil cache['content-desc']
          assert_nil cache.content_desc
        else
          assert_equal value, cache.attributes['attribute/content-desc']
          assert_equal value, cache['content-desc']
          assert_equal value, cache.content_desc
        end
      end
    end

    private

    def response(id = 'id', text = 'original')
      { Appium::Core::Element::ELEMENT_KEY => id, 'text' => text, 'enabled' => false, 'attribute/content-desc' => 'label' }
    end

    def stub_value(method, path, value)
      stub_request(method, "#{SESSION}#{path}").to_return(headers: HEADER, body: { value: value }.to_json)
    end
  end
end
