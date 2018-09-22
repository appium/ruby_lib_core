require 'test_helper'

# $ rake test:func:android TEST=test/functional/android/driver_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  class DriverTest < AppiumLibCoreTest::Function::TestCase
    def setup
      @@core ||= ::Appium::Core.for(Caps.android)
      @driver = @@core.start_driver
    end

    def teardown
      save_reports(@driver)
    end

    def test_appium_server_version
      v = @@core.appium_server_version

      refute_nil v['build']['version']
    end

    def test_platform_version
      # @@core.platform_version #=> [7, 1, 1]
      assert @@core.platform_version.length > 1
    end

    def test_screenshot
      file = @@core.screenshot './android_test.png'

      assert File.exist?(file.path)

      File.delete file.path
      assert !File.exist?(file.path)
    end

    def test_wait_true
      e = @@core.wait_true { @driver.find_element :accessibility_id, 'Content' }
      assert e.text
    end

    def test_wait
      e = @@core.wait { @driver.find_element :accessibility_id, 'Content' }
      assert_equal 'Content', e.text
    end

    # @since Appium 1.9.2
    def test_mobile_perform_action
      @driver.find_element(:accessibility_id, 'App').click
      @driver.find_element(:accessibility_id, 'Activity').click
      @driver.find_element(:accessibility_id, 'Custom Title').click

      e = @driver.find_element :id, 'io.appium.android.apis:id/left_text_edit'
      e.click

      assert_equal 'Left is best', e.text
      assert_equal 'true', e.focused

      @driver.execute_script 'mobile: performEditorAction', { action: 'normal' }
      assert_equal 'false', e.focused

      new_element = @driver.find_element :xpath, '//*[@focused="true"]'
      assert_equal 'Right is always right', new_element.text
    end

    # TODO: call @driver.quit after tests
  end
end
