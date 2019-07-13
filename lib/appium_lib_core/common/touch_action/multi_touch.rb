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
    # MultiTouch actions allow for multiple touches to happen at the same time,
    # for instance, to simulate multiple finger swipes.
    #
    # Create a series of touch actions by themselves (without a +prepare()+), then
    # add to a new MultiTouch action.  When ready, call +prepare()+ and all
    # actions will be executed simultaneously.
    #
    # @example
    #
    #   @driver = Appium::Core.for(opts).start_driver
    #   action_1 = TouchAction.new(@driver).press(x: 45, y: 100).wait(600).release
    #   action_2 = TouchAction.new(@driver).tap(element: el, x: 50, y:5, count: 3)
    #
    #   multi_touch_action = MultiTouch.new(@driver)
    #   multi_touch_action.add action_1
    #   multi_touch_action.add action_2
    #   multi_touch_action.perform
    #
    class MultiTouch
      attr_reader :driver

      def initialize(driver)
        @actions = []
        @driver = driver
      end

      # Add a touch_action to be performed
      # @param chain (TouchAction) The action to add to the chain
      def add(chain)
        @actions << chain.actions
      end

      # Ask Appium to perform the actions
      def perform
        @driver.multi_touch @actions
        @actions.clear
      end
    end # class MultiTouch
  end # module Core
end # module Appium
