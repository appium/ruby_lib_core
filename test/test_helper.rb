$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'appium_lib_core'

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest'
$VERBOSE = nil

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class AppiumLibCoreTest
  module Caps
    # Require a simulator which OS version is 10.3, for example.
    IOS_OPS = {
      caps: {
        platformName: :ios,
        automationName: 'XCUITest',
        app: 'test/functional/app/UICatalog.app',
        platformVersion: '10.3',
        deviceName: 'iPhone Simulator',
        useNewWDA: true,
        some_capability: 'some_capability'
      },
      appium_lib: {
        export_session: true,
        wait: 30,
        wait_timeout: 20,
        wait_interval: 1
      }
    }.freeze

    # Require a real device or an emulator.
    # We should update platformVersion and deviceName to fit your environment.
    ANDROID_OPS = {
      caps: {
        platformName: :android,
        automationName: 'uiautomator2',
        app: 'test/functional/app/api.apk',
        platformVersion: '6.0',
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

  module Mock
    HEADER = { 'Content-Type' => 'application/json; charset=utf-8', 'Cache-Control' => 'no-cache' }.freeze
    SESSION = 'http://127.0.0.1:4723/wd/hub/session/1234567890'.freeze

    def android_mock_create_session
      response = {
        status: 0, # To make bridge.dialect == :oss
        value: {
          sessionId: '1234567890',
          capabilities: {
            platform: 'LINUX',
            webStorageEnabled: false,
            takesScreenshot: true,
            javascriptEnabled: true,
            databaseEnabled: false,
            networkConnectionEnabled: true,
            locationContextEnabled: false,
            warnings: {},
            desired: {
              platformName: 'Android',
              automationName: 'uiautomator2',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              app: '/test/apps/ApiDemos-debug.apk',
              newCommandTimeout: 240,
              unicodeKeyboard: true,
              resetKeyboard: true
            },
            platformName: 'Android',
            automationName: 'uiautomator2',
            platformVersion: '7.1.1',
            deviceName: 'emulator-5554',
            app: '/test/apps/ApiDemos-debug.apk',
            newCommandTimeout: 240,
            unicodeKeyboard: true,
            resetKeyboard: true,
            deviceUDID: 'emulator-5554',
            deviceScreenSize: '1080x1920',
            deviceModel: 'Android SDK built for x86_64',
            deviceManufacturer: 'unknown',
            appPackage: 'com.example.android.apis',
            appWaitPackage: 'com.example.android.apis',
            appActivity: 'com.example.android.apis.ApiDemos',
            appWaitActivity: 'com.example.android.apis.ApiDemos'
          }
        }
      }.to_json

      stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
        .to_return(headers: HEADER, status: 200, body: response)

      stub_request(:post, "#{SESSION}/timeouts/implicit_wait")
        .with(body: { ms: 30_000 }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

      driver = @core.start_driver

      assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
      assert_requested(:post, "#{SESSION}/timeouts/implicit_wait", times: 1)
      driver
    end

    def ios_mock_create_session
      response = {
        status: 0, # To make bridge.dialect == :oss
        sessionId: '1234567890',
        value: {
          capabilities: {
            device: 'iphone',
            browserName: 'UICatalog',
            sdkVersion: '10.3.1',
            CFBundleIdentifier: 'com.example.apple-samplecode.UICatalog'
          }
        }
      }.to_json

      stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
        .to_return(headers: HEADER, status: 200, body: response)

      stub_request(:post, "#{SESSION}/timeouts/implicit_wait")
        .with(body: { ms: 30_000 }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

      driver = @core.start_driver

      assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
      assert_requested(:post, "#{SESSION}/timeouts/implicit_wait", times: 1)
      driver
    end
  end
end
