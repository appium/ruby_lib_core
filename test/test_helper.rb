$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'appium_lib_core'

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest'
$VERBOSE = nil

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class AppiumLibCoreTest
  module Caps
    IOS_OPS = {
      caps: {
        platformName: :ios,
        automationName: 'XCUITest',
        app: 'test/app/UICatalog.app',
        platformVersion: '10.3',
        deviceName: 'iPhone Simulator',
        some_capability: 'some_capability'
      },
      appium_lib: {
        export_session: true,
        wait: 30,
        wait_timeout: 20,
        wait_interval: 1
      }
    }.freeze

    ANDROID_OPS = {
      caps: {
        platformName: :android,
        automationName: 'uiautomator2',
        app: 'test/app/api.apk',
        platformVersion: '7.1.1',
        deviceName: 'Android Emulator',
        appPackage: 'io.appium.android.apis',
        appActivity: 'io.appium.android.apis.ApiDemos',
        some_capability: 'some_capability',
        unicodeKeyboard: true,
        resetKeyboard: true
      },
      appium_lib: {
        export_session: true,
        wait: 30,
        wait_timeout: 20,
        wait_interval: 1
      }
    }.freeze
  end
end
