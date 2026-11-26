# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'

class WinCoreTest < Minitest::Test
  def setup
    app = File.join(ENV.fetch('SystemRoot'), 'System32', 'notepad.exe')
    caps = {
      platformName: 'Windows',
      automationName: 'Wincore',
      app: app,
      'appium:ms:waitForAppLaunch' => 15,
      'appium:ms:forcequit' => true
    }
    @driver = Appium::Core.for(capabilities: caps).start_driver
  end

  def teardown
    @driver&.quit
  end

  def test_find_menu_item
    condition = "[PropertyCondition]::new([AutomationElement]::NameProperty, 'File')"
    @driver.manage.timeouts.implicit_wait = 10
    assert @driver.find_element(:windows_uiautomation, condition).displayed?
  end

  def test_save_screen_recording
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'desktop.mp4')
      @driver.start_recording_screen(fps: 5, time_limit: 10)
      sleep 2 # Capture several frames before stopping ffmpeg.
      @driver.stop_and_save_recording_screen(path)
      assert_equal 'ftyp', File.binread(path, 4, 4)
    end
  end
end
