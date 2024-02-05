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

class AppiumLibCoreTest
  class ImageElementTest < Minitest::Test
    include AppiumLibCoreTest::Mock

    def setup
      @core ||= ::Appium::Core.for(Caps.android)
      @driver ||= android_mock_create_session_w3c
    end

    def test_w3c
      stub_request(:post, "#{SESSION}/element")
        .with(body: { using: '-image', value: 'base64 string' }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value:
          { ::Appium::Core::Element::ELEMENT_KEY =>
            'appium-image-element-bb24f75c-5c15-478d-bb38-c003788aa5f8' } }.to_json)

      e = @driver.find_element :image, 'base64 string'

      assert_requested(:post, "#{SESSION}/element", times: 1)
      assert_equal ::Appium::Core::Element, e.class
      assert_equal 'appium-image-element-bb24f75c-5c15-478d-bb38-c003788aa5f8', e.id
    end
  end
end
