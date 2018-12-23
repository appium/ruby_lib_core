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
          # iOS
          uiautomation:         '-ios uiautomation',
          predicate:            '-ios predicate string',
          class_chain:          '-ios class chain',
          # Windows
          windows_uiautomation: '-windows uiautomation',
          # Tizen
          tizen_uiautomation:   '-tizen uiautomation'
        )
        # rubocop:enable Layout/AlignHash

        #
        # Find the first element matching the given arguments
        #
        # Android can find with uiautomator like a [UISelector](http://developer.android.com/tools/help/uiautomator/UiSelector.html).
        # iOS can find with a [UIAutomation command](https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIAWindowClassReference/UIAWindow/UIAWindow.html#//apple_ref/doc/uid/TP40009930).
        # iOS, only for XCUITest(WebDriverAgent), can find with a [class chain]( https://github.com/facebook/WebDriverAgent/wiki/Queries)
        #
        # Find with image.
        # Return an element if current view has a partial image. The logic depends on template matching by OpenCV.
        # @see https://github.com/appium/appium/blob/master/docs/en/writing-running-appium/image-comparison.md
        # You can handle settings for the comparision following below.
        # @see https://github.com/appium/appium-base-driver/blob/master/lib/basedriver/device-settings.js#L6
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
        #     find_elements :accessibility_id, 'Animation'
        #     find_elements :accessibility_id, 'Animation'
        #
        #     # with base64 encoded template image. All platforms.
        #     find_elements :image, Base64.strict_encode64(File.read(file_path))
        #
        #     # For Android
        #     ## With uiautomator
        #     find_elements :uiautomator, 'new UiSelector().clickable(true)'
        #     ## With viewtag, but only for Espresso
        #     ## `setTag`/`getTag` in https://developer.android.com/reference/android/view/View
        #     find_elements :viewtag, 'new UiSelector().clickable(true)'
        #
        #     # For iOS
        #     ## With :predicate
        #     find_elements :predicate, "isWDVisible == 1"
        #     find_elements :predicate, 'wdName == "Buttons"'
        #     find_elements :predicate, 'wdValue == "SearchBar" AND isWDDivisible == 1'
        #
        #     ## With Class Chain
        #     ### select the third child button of the first child window element
        #     find_elements :class_chain, 'XCUIElementTypeWindow/XCUIElementTypeButton[3]'
        #     ### select all the children windows
        #     find_elements :class_chain, 'XCUIElementTypeWindow'
        #     ### select the second last child of the second child window
        #     find_elements :class_chain, 'XCUIElementTypeWindow[2]/XCUIElementTypeAny[-2]'
        #     ### matching predicate. <code>`</code> is the mark.
        #     find_elements :class_chain, 'XCUIElementTypeWindow[`visible = 1][`name = "bla"`]'
        #     ### containing predicate. `$` is the mark.
        #     ### Require appium-xcuitest-driver 2.54.0+. PR: https://github.com/facebook/WebDriverAgent/pull/707/files
        #     find_elements :class_chain, 'XCUIElementTypeWindow[$name = \"bla$$$bla\"$]'
        #     e = find_element :class_chain, "**/XCUIElementTypeWindow[$name == 'Buttons'$]"
        #     e.tag_name #=> "XCUIElementTypeWindow"
        #     e = find_element :class_chain, "**/XCUIElementTypeStaticText[$name == 'Buttons'$]"
        #     e.tag_name #=> "XCUIElementTypeStaticText"
        #
        #     # For Windows
        #     find_elements :windows_uiautomation, '....'
        #
        #     # For Tizen
        #     find_elements :tizen_uiautomation, '....'
        #
        def find_element(*args)
          how, what = extract_args(args)
          by = _set_by_from_finders(how)
          begin
            bridge.find_element_by by, what.to_s, ref
          rescue Selenium::WebDriver::Error::TimeOutError
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
          rescue Selenium::WebDriver::Error::TimeOutError
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
