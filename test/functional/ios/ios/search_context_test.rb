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

# $ rake test:func:ios TEST=test/functional/ios/ios/search_context_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module Ios
    class SearchContextTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core = ::Appium::Core.for(Caps.ios)
        @@driver = @@core.start_driver
      end

      def teardown
        save_reports(@@driver)
      end

      def test_predicate
        e = @@driver.find_element :predicate, 'wdName == "Buttons"'
        assert_equal 'Buttons', e.name
      end

      def test_class_chain
        e = @@driver.find_element :class_chain, "**/XCUIElementTypeWindow[$name == 'Buttons'$]"
        assert_equal 'XCUIElementTypeWindow', e.tag_name
      end
    end
  end
end
# rubocop:enable Style/ClassVars
