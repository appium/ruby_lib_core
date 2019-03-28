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

# $ rake test:func:ios TEST=test/functional/ios/tv_driver_test.rb
class AppiumLibCoreTest
  class TvDriverTest < AppiumLibCoreTest::Function::TestCase
    def setup
      @core = ::Appium::Core.for(Caps.ios(:tvos))

      @driver = @core.start_driver
    end

    def teardown
      save_reports(@driver)
    end

    def test_launch_app
      test_package = 'com.kazucocoa.tv-example'

      e = @driver.find_element :name, 'Second'
      e.click

      @core.wait { @driver.find_element :name, 'Second View' }
      assert_equal :running_in_foreground, @driver.app_state(test_package)

      @driver.terminate_app test_package
      assert_equal :not_running, @driver.app_state(test_package)

      @driver.activate_app test_package
      assert_equal :running_in_foreground, @driver.app_state(test_package)

      @driver.execute_script 'mobile: pressButton', { name: 'Home' }
      assert @core.wait_true do
        @driver.app_state(test_package) == :running_in_background_suspended
      end
    end
  end
end
