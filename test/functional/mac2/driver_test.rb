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

# $ rake test:func:ios TEST=test/functional/mac2/driver_test.rb
class AppiumLibCoreTest
  class DriverTest < AppiumLibCoreTest::Function::TestCase
    def setup
      @core = ::Appium::Core.for(Caps.mac2)
      @driver = @core.start_driver

      require 'pry'
      binding.pry
    end

    def teardown
      save_reports(@driver)
    end

    def test_first
      @driver.page_source
      e = @driver.find_element :name, 'Apple'
      e.click

      e = @driver.find_element :name, 'About This Mac'
      e.click
    end
  end
end
