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

# $ rake test:func:ios TEST=test/functional/ios/ios/mobile_commands_test.rb
class AppiumLibCoreTest
  module Ios
    class MobileCommandsTest < AppiumLibCoreTest::Function::TestCase
      private

      def uicatalog
        over_ios13?(@driver) ? 'UIKitCatalog' : 'UICatalog'
      end

      public

      def setup
        @core = ::Appium::Core.for(Caps.ios)
      end

      def teardown
        save_reports(@driver)
      end

      def test_select_picker_wheel
        @driver = @core.start_driver
        @driver.find_element(:id, 'Picker View').click

        elements = @driver.find_elements :class, 'XCUIElementTypePickerWheel'
        assert_equal '65', elements[0].value

        args = { element: elements[0].id, order: :next }
        @driver.execute_script 'mobile: selectPickerWheelValue', args
        # 'Chris Armstrong' is the next. 'Serena Auroux' is 2 steps next.
        # iOS 13.0 selects 'chris armstrong' (expected) while iOS 12.x selects 'Serena Auroux' sometimes
        assert %w(70 75).include?(elements[0].value)

        args = { element: elements[0].id, order: :previous }
        @driver.execute_script 'mobile: selectPickerWheelValue', args
        assert_equal '65', elements[0].value
      end

      def test_pasteboard
        skip_as_appium_version '1.9.0'

        @driver = @core.start_driver

        message = 'happy appium'

        args = { content: message }
        @driver.execute_script 'mobile: setPasteboard', args
        assert_equal message, @driver.get_clipboard # does not work? Make sure this is because of iOS 13 or Xcode 11

        # Base64 which follows RFC 2045 inserts new line every 60 chars
        # Ruby client sends it as RFC 4648 (Base64.strict_encode64)
        message = 'ハッピー testing GgoAAAANSUhEUgAAAu4AAAU2CAIAAABFtaRRAAAAAXNSR0IArs4c6QAAABxpRE9UAAAAAgAAAAAAAA'
        args = { content: message, encoding: 'utf-8' }
        @driver.execute_script 'mobile: setPasteboard', args

        # Ruby decode the string as ASCII-8BIT in Base64.encode64
        assert_equal message, @driver.get_clipboard.force_encoding('utf-8')
      end

      # @since Appium 1.10.0
      # Requires simulator
      def test_permission
        skip_as_appium_version '1.10.0'

        caps = Caps.ios.dup
        caps[:caps][:permissions] = '{"com.example.apple-samplecode.UICatalog": { "calendar": "YES", "photos": "no" }}'
        core = ::Appium::Core.for(caps)
        @driver = core.start_driver

        skip 'Permissions does not work well on iOS 14 yet' if over_ios14?(@driver)

        assert @driver.execute_script('mobile: getPermission',
                                      { service: 'calendar', bundleId: 'com.example.apple-samplecode.UICatalog' }) == 'yes'
        assert @driver.execute_script('mobile: getPermission',
                                      { service: 'photos', bundleId: 'com.example.apple-samplecode.UICatalog' }) == 'no'

        @driver.terminate_app('com.apple.Preferences') # To ensure the app shows the top view
        @driver.activate_app('com.apple.Preferences')
        @driver.find_element(:accessibility_id, 'Privacy').click

        @driver.find_element(:accessibility_id, 'Calendars').click
        el = @driver.find_element(:accessibility_id, uicatalog)
        assert_equal '1', el.value

        @driver.back

        @driver.find_element(:accessibility_id, 'Photos').click
        el = @driver.find_element(:accessibility_id, 'Never')
        assert_equal 'Never', el.value
      end

      # @since Appium 1.10.0
      def test_siri
        skip_as_appium_version '1.10.0'

        skip 'Not stable on CI' if ci?

        @driver = @core.start_driver

        assert @driver.app_state('com.example.apple-samplecode.UICatalog') == :running_in_foreground
        assert @driver.app_state('com.apple.SiriViewService') != :running_in_foreground

        @driver.execute_script 'mobile: siriCommand', { text: 'hello, siri' }

        if over_ios14?(@driver)
          @core.wait { @driver.find_element :name, 'siri-interface-window' }
        else
          # Siri returns below element if it has connection issue
          # <XCUIElementTypeStaticText type="XCUIElementTypeStaticText" ....
          #   name="...having a problem with the connection. Please try again in a little bit." ...>
          @core.wait { @driver.find_element :class_chain, '**/*[`name == "com.apple.ace.assistant"`]' }
        end
        assert_equal :running_in_foreground, @driver.app_state('com.example.apple-samplecode.UICatalog')

        @driver.activate_app 'com.example.apple-samplecode.UICatalog'
        sleep 1 # wait a bit for switching siri service with the test target app
        @core.wait { assert_equal :running_in_foreground, @driver.app_state('com.example.apple-samplecode.UICatalog') }
      end

      def test_source
        @driver = @core.start_driver

        json = @driver.execute_script 'mobile: source', { format: :json }
        xml = @driver.execute_script 'mobile: source', { format: :xml }
        description = @driver.execute_script 'mobile: source', { format: :description }

        assert !json.empty?
        assert !xml.empty?
        assert !description.empty? # get a vanilla xcuitest description data

        xml2 = @driver.execute_script 'mobile: source', { format: :xml, excludedAttributes: ['visible'] }
        assert !xml2.empty?
      end

      def test_device_info
        skip_as_appium_version '1.15.0'

        @driver = @core.start_driver

        assert @driver.execute_script('mobile: deviceInfo', {}).size.positive?
      end
    end
  end
end
