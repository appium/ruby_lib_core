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
    # Perform a series of gestures, one after another.  Gestures are chained
    # together and only performed when +perform()+ is called. Default is conducted by global driver.
    #
    # Each method returns the object itself, so calls can be chained.
    #
    # Consider to use W3C spec touch action like the followings.
    # https://seleniumhq.github.io/selenium/docs/api/rb/Selenium/WebDriver/W3CActionBuilder.html
    # https://github.com/appium/ruby_lib_core/blob/master/test/functional/android/webdriver/w3c_actions_test.rb
    # https://github.com/appium/ruby_lib_core/blob/master/test/functional/ios/webdriver/w3c_actions_test.rb
    #
    # @example
    #
    #   @driver = Appium::Core.for(opts).start_driver
    #   action = TouchAction.new(@driver).press(x: 45, y: 100).wait(600).release
    #   action.perform
    #   action = TouchAction.new(@driver).swipe(....)
    #   action.perform
    #
    class TouchAction
      ACTIONS = %i(move_to long_press double_tap two_finger_tap press release tap wait perform).freeze
      COMPLEX_ACTIONS = %i(swipe).freeze

      attr_reader :actions, :driver

      def initialize(driver)
        @actions = []
        @driver = driver
      end

      # Move to the given co-ordinates.
      #
      # +move_to+'s +x+ and +y+ have two case. One is working as coordinate, the other is working as offset.
      #
      # @param opts [Hash] Options
      # @option opts [integer] :x x co-ordinate to move to if element isn't set. Works as an absolute if x is set with Element.
      # @option opts [integer] :y y co-ordinate to move to if element isn't set. Works as an absolute if y is set with Element.
      # @option opts [WebDriver::Element] Element to scope this move within.
      def move_to(opts)
        opts = args_with_ele_ref(opts)
        chain_method(:moveTo, opts)
      end

      # Press down for a specific duration.
      # Alternatively, you can use +press(...).wait(...).release()+ instead of +long_press+ if duration doesn't work well.
      # https://github.com/appium/ruby_lib/issues/231#issuecomment-269895512
      # e.g. Appium::TouchAction.new.press(x: 280, y: 530).wait(2000).release.perform
      #
      # @param opts [Hash] Options
      # @option opts [WebDriver::Element] element the element to press.
      # @option opts [integer] x X co-ordinate to press on.
      # @option opts [integer] y Y co-ordinate to press on.
      # @option opts [integer] duration Number of milliseconds to press.
      def long_press(opts)
        args = opts.select { |k, _v| %i(element x y duration).include? k }
        args = args_with_ele_ref(args)
        chain_method(:longPress, args) # longPress is what the appium server expects
      end

      # Press a finger onto the screen.  Finger will stay down until you call +release+.
      #
      # @param opts [Hash] Options
      # @option opts [WebDriver::Element] :element (Optional) Element to press within.
      # @option opts [integer] :x x co-ordinate to press on
      # @option opts [integer] :y y co-ordinate to press on
      # @option opts [Float] pressure (iOS Only) press as force touch.
      #                                          See the description of +force+ property on Apple's UITouch class
      #                                          (https://developer.apple.com/documentation/uikit/uitouch?language=objc)
      #                                          for more details on possible value ranges.
      def press(opts)
        args = opts.select { |k, _v| %i(element x y).include? k }
        args = args_with_ele_ref(args)
        args[:pressure] = opts.delete(:pressure) unless opts[:pressure].nil?
        chain_method(:press, args)
      end

      # Remove a finger from the screen.
      #
      # @param opts [Hash] Options
      # @option opts [WebDriver::Element] :element (Optional) Element to release from.
      # @option opts [integer] :x x co-ordinate to release from
      # @option opts [integer] :y y co-ordinate to release from
      def release(opts = nil)
        args = args_with_ele_ref(opts) if opts
        chain_method(:release, args)
      end

      # Touch a point on the screen.
      # Alternatively, you can use +press(...).release.perform+ instead of +tap(...).perform+.
      #
      # @param opts [Hash] Options
      # @option opts [WebDriver::Element] :element (Optional) Element to restrict scope too.
      # @option opts [integer] :x x co-ordinate to tap
      # @option opts [integer] :y y co-ordinate to tap
      # @option opts [integer] :fingers how many fingers to tap with (Default 1)
      def tap(opts)
        opts[:count] = opts.delete(:fingers) if opts[:fingers]
        opts[:count] ||= 1
        args = args_with_ele_ref opts
        chain_method(:tap, args)
      end

      # Double tap an element on the screen
      #
      # @param opts [Hash] Options
      # @option opts [WebDriver::Element] :element (Optional) Element to restrict scope too.
      # @option opts [integer] :x x co-ordinate to tap
      # @option opts [integer] :y y co-ordinate to tap

      def double_tap(opts)
        args = opts.select { |k, _v| %i(element x y).include? k }
        args = args_with_ele_ref(args)
        chain_method(:doubleTap, args) # doubleTap is what the appium server expects
      end

      # Two finger tap an element on the screen
      #
      # @param opts [Hash] Options
      # @option opts [WebDriver::Element] :element (Optional) Element to restrict scope too.
      # @option opts [integer] :x x co-ordinate to tap
      # @option opts [integer] :y y co-ordinate to tap
      def two_finger_tap(opts)
        args = opts.select { |k, _v| %i(element x y).include? k }
        args = args_with_ele_ref(args)
        chain_method(:twoFingerTap, args) # twoFingerTap is what the appium server expects
      end

      # Pause for a number of milliseconds before the next action
      # @param milliseconds [integer] Number of milliseconds to pause for
      def wait(milliseconds)
        args = { ms: milliseconds }
        chain_method(:wait, args)
      end

      # Convenience method to perform a swipe.
      #
      # @param opts [Hash] Options
      # @option opts [int] :start_x Where to start swiping, on the x axis.  Default 0.
      # @option opts [int] :start_y Where to start swiping, on the y axis.  Default 0.
      # @option opts [int] :end_x Move to the end, on the x axis.  Default 0.
      # @option opts [int] :end_y Move to the end, on the y axis.  Default 0.
      # @option opts [int] :duration How long the actual swipe takes to complete in milliseconds. Default 200.
      def swipe(opts)
        start_x = opts.fetch :start_x, 0
        start_y = opts.fetch :start_y, 0
        end_x   = opts.fetch :end_x, 0
        end_y   = opts.fetch :end_y, 0

        duration = opts.fetch :duration, 200

        press x: start_x, y: start_y
        wait(duration) if duration
        move_to x: end_x, y: end_y

        release

        self
      end

      # Ask the driver to perform all actions in this action chain.
      def perform
        @driver.touch_actions @actions
        @actions.clear
        self
      end

      # Does nothing, currently.
      def cancel
        @actions << { action: cancel }
        @driver.touch_actions @actions
        self
      end

      private

      def chain_method(method, args = nil)
        action = args ? { action: method, options: args } : { action: method }
        @actions << action
        self
      end

      def args_with_ele_ref(args)
        args[:element] = args[:element].ref if args.key? :element
        args
      end
    end # class TouchAction
  end # module Core
end # module Appium
