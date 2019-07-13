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
    class Base
      module SearchContext
        # referenced: ::Selenium::WebDriver::SearchContext

        # rubocop:disable Layout/AlignHash
        FINDERS = ::Selenium::WebDriver::SearchContext::FINDERS.merge(
          accessibility_id:     'accessibility id',
          image:                '-image',
          custom:               '-custom',
          # Android
          uiautomator:          '-android uiautomator', # Unavailable in Espresso
          viewtag:              '-android viewtag',     # Available in Espresso
          data_matcher:         '-android datamatcher', # Available in Espresso
          # iOS
          uiautomation:         '-ios uiautomation',
          predicate:            '-ios predicate string',
          class_chain:          '-ios class chain',
          # Windows with windows prefix
          windows_uiautomation: '-windows uiautomation',
          # Tizen with Tizen prefix
          tizen_uiautomation:   '-tizen uiautomation'
        )
        # rubocop:enable Layout/AlignHash

        # rubocop:disable Metrics/LineLength
        #
        # Find the first element matching the given arguments
        #
        # - Android can find with uiautomator like a {http://developer.android.com/tools/help/uiautomator/UiSelector.html UISelector}.
        # - iOS can find with a {https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIAWindowClassReference/UIAWindow/UIAWindow.html#//apple_ref/doc/uid/TP40009930 UIAutomation command}.
        # - iOS, only for XCUITest(WebDriverAgent), can find with a {https://github.com/facebook/WebDriverAgent/wiki/Queries class chain}
        #
        # == Find with image
        # Return an element if current view has a partial image. The logic depends on template matching by OpenCV.
        # {https://github.com/appium/appium/blob/master/docs/en/writing-running-appium/image-comparison.md image-comparison}
        #
        # You can handle settings for the comparision following {https://github.com/appium/appium-base-driver/blob/master/lib/basedriver/device-settings.js#L6 here}
        #
        # == Espresso datamatcher
        # Espresso has an {https://medium.com/androiddevelopers/adapterviews-and-espresso-f4172aa853cf _onData_ matcher} for more reference
        # that allows you to target adapters instead of Views. This method find methods based on reflections
        #
        # This is a selector strategy that allows users to pass a selector of the form:
        #
        # <code>{ name: '<name>', args: ['arg1', 'arg2', '...'], class: '<optional class>' }</code>
        #
        # - _name_: The name of a method to invoke. The method must return
        # a Hamcrest {http://hamcrest.org/JavaHamcrest/javadoc/1.3/org/hamcrest/Matcher.html Matcher}
        # - _args_: The args provided to the method
        # - _class_: The class name that the method is part of (defaults to <code>org.hamcrest.Matchers</code>).
        # Can be fully qualified, or simple, and simple defaults to <code>androidx.test.espresso.matcher</code> package
        # (e.g.: <code>class=CursorMatchers</code> fully qualified is <code>class=androidx.test.espresso.matcher.CursorMatchers</code>
        #
        # See example how to send datamatcher in Ruby client
        #
        #
        # @overload find_element(how, what)
        #   @param [Symbol, String] how The method to find the element by
        #   @param [String] what The locator to use
        #
        # @overload find_element(opts)
        #   @param [Hash] opts Find options
        #   @option opts [Symbol] :how Key named after the method to find the element by, containing the locator
        # @return [Element]
        # @raise [Error::NoSuchElementError] if the element doesn't exist
        #
        # @example Find element with each keys
        #
        #     # with accessibility id. All platforms.
        #     @driver.find_elements :accessibility_id, 'Animation'
        #     @driver.find_elements :accessibility_id, 'Animation'
        #
        #     # with base64 encoded template image. All platforms.
        #     @driver.find_elements :image, Base64.strict_encode64(File.read(file_path))
        #
        #     # For Android
        #     ## With uiautomator
        #     @driver.find_elements :uiautomator, 'new UiSelector().clickable(true)'
        #     ## With viewtag, but only for Espresso
        #     ## 'setTag'/'getTag' in https://developer.android.com/reference/android/view/View
        #     @driver.find_elements :viewtag, 'new UiSelector().clickable(true)'
        #     # With data_matcher. The argument should be JSON format.
        #     @driver.find_elements :data_matcher, { name: 'hasEntry', args: %w(title Animation) }.to_json
        #
        #     # For iOS
        #     ## With :predicate
        #     @driver.find_elements :predicate, "isWDVisible == 1"
        #     @driver.find_elements :predicate, 'wdName == "Buttons"'
        #     @driver.find_elements :predicate, 'wdValue == "SearchBar" AND isWDDivisible == 1'
        #
        #     ## With Class Chain
        #     ### select the third child button of the first child window element
        #     @driver.find_elements :class_chain, 'XCUIElementTypeWindow/XCUIElementTypeButton[3]'
        #     ### select all the children windows
        #     @driver.find_elements :class_chain, 'XCUIElementTypeWindow'
        #     ### select the second last child of the second child window
        #     @driver.find_elements :class_chain, 'XCUIElementTypeWindow[2]/XCUIElementTypeAny[-2]'
        #     ### matching predicate. <code>'</code> is the mark.
        #     @driver.find_elements :class_chain, 'XCUIElementTypeWindow['visible = 1]['name = "bla"']'
        #     ### containing predicate. '$' is the mark.
        #     ### Require appium-xcuitest-driver 2.54.0+. PR: https://github.com/facebook/WebDriverAgent/pull/707/files
        #     @driver.find_elements :class_chain, 'XCUIElementTypeWindow[$name = \"bla$$$bla\"$]'
        #     e = find_element :class_chain, "**/XCUIElementTypeWindow[$name == 'Buttons'$]"
        #     e.tag_name #=> "XCUIElementTypeWindow"
        #     e = find_element :class_chain, "**/XCUIElementTypeStaticText[$name == 'Buttons'$]"
        #     e.tag_name #=> "XCUIElementTypeStaticText"
        #
        #     # For Windows
        #     @driver.find_elements :windows_uiautomation, '....'
        #
        #     # For Tizen
        #     @driver.find_elements :tizen_uiautomation, '....'
        #
        # rubocop:enable Metrics/LineLength
        def find_element(*args)
          how, what = extract_args(args)
          by = _set_by_from_finders(how)
          begin
            bridge.find_element_by by, what.to_s, ref
          rescue Selenium::WebDriver::Error::TimeOutError # will deprecate
            raise Selenium::WebDriver::Error::NoSuchElementError
          rescue Selenium::WebDriver::Error::TimeoutError
            raise Selenium::WebDriver::Error::NoSuchElementError
          end
        end

        #
        # Find all elements matching the given arguments
        #
        # @see SearchContext#find_elements
        #
        def find_elements(*args)
          how, what = extract_args(args)
          by = _set_by_from_finders(how)
          begin
            bridge.find_elements_by by, what.to_s, ref
          rescue Selenium::WebDriver::Error::TimeOutError # will deprecate
            []
          rescue Selenium::WebDriver::Error::TimeoutError
            []
          end
        end

        private

        def _set_by_from_finders(how)
          by = FINDERS[how.to_sym]
          raise ArgumentError, "cannot find element by #{how.inspect}. Available finders are #{FINDERS.keys}." unless by

          by
        end

        def extract_args(args)
          case args.size
          when 2
            args
          when 1
            arg = args.first

            raise ArgumentError, "expected #{arg.inspect}:#{arg.class} to respond to #shift" unless arg.respond_to?(:shift)

            # this will be a single-entry hash, so use #shift over #first or #[]
            arr = arg.dup.shift

            raise ArgumentError, "expected #{arr.inspect} to have 2 elements" unless arr.size == 2

            arr
          else
            raise ArgumentError, "wrong number of arguments (#{args.size} for 2)"
          end
        end
      end # module SearchContext
    end # class Base
  end # module Core
end # module Appium
