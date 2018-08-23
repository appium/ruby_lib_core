require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/common/element_test.rb
class AppiumLibCoreTest
  class ElementTest < Minitest::Test
    include AppiumLibCoreTest::Mock

    def setup
      @core ||= ::Appium::Core.for(self, Caps.android)
      @driver ||= android_mock_create_session_w3c
    end

    def test_method_missing
      stub_request(:get, "#{SESSION}/element/id/attribute/content-desc")
        .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

      e = ::Selenium::WebDriver::Element.new(@driver.send(:bridge), 'id')
      e.content_desc

      assert_requested(:get, "#{SESSION}/element/id/attribute/content-desc", times: 1)
    end
  end
end
