require 'test_helper'

class AppiumLibCoreTest
  class ImageElementTest < Minitest::Test
    include AppiumLibCoreTest::Mock

    def setup
      @core ||= ::Appium::Core.for(self, Caps.ios)
    end

    def test_mjsonwp
      driver ||= ios_mock_create_session

      stub_request(:post, "#{SESSION}/element")
        .with(body: { using: '-image', value: 'base64 string' }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value:
          { 'element-6066-11e4-a52e-4f735466cecf':
            'appium-image-element-bb24f75c-5c15-478d-bb38-c003788aa5f8' } }.to_json)

      e = driver.find_element :image, 'base64 string'

      assert_requested(:post, "#{SESSION}/element", times: 1)
      assert_equal 'appium-image-element-bb24f75c-5c15-478d-bb38-c003788aa5f8', e.ref
    end

    def test_w3c
      driver ||= ios_mock_create_session_w3c

      stub_request(:post, "#{SESSION}/element")
        .with(body: { using: '-image', value: 'base64 string' }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value:
          { 'element-6066-11e4-a52e-4f735466cecf':
            'appium-image-element-bb24f75c-5c15-478d-bb38-c003788aa5f8' } }.to_json)

      e = driver.find_element :image, 'base64 string'

      assert_requested(:post, "#{SESSION}/element", times: 1)
      assert_equal 'appium-image-element-bb24f75c-5c15-478d-bb38-c003788aa5f8', e.ref
    end
  end
end
