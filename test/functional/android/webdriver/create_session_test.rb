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

# $ rake test:func:android TEST=test/functional/android/webdriver/create_session_test.rb
class AppiumLibCoreTest
  module WebDriver
    class CreateSessionTestTest < AppiumLibCoreTest::Function::TestCase
      def test_w3c_default
        skip_as_appium_version '1.8.0'

        caps = Caps.android
        core = ::Appium::Core.for(caps)

        driver = core.start_driver
        assert !driver.capabilities.nil?

        driver&.quit
      end
    end
  end
end
