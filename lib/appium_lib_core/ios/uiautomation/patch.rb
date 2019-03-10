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

module Appium
  module Core
    module Ios
      module Uiautomation
        # @private
        # class_eval inside a method because class Selenium::WebDriver::Element
        # will trigger as soon as the file is required. in contrast a method
        # will trigger only when invoked.
        def self.patch_webdriver_element
          ::Selenium::WebDriver::Element.class_eval do
            # Cross platform way of entering text into a textfield
            def type(text, driver)
              driver.execute_script %(au.getElement('#{ref}').setValue('#{text}');)
            end # def type
          end # Selenium::WebDriver::Element.class_eval
        end # def patch_webdriver_element
      end # module Uiautomation
    end # module Ios
  end # module Core
end # module Appium
