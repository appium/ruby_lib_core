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
  end
end
