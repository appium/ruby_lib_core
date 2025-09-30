# AppiumLibCore

[![Gem Version](https://badge.fury.io/rb/appium_lib_core.svg)](https://badge.fury.io/rb/appium_lib_core)

[![Runs lint and unit tests](https://github.com/appium/ruby_lib_core/actions/workflows/unittest.yml/badge.svg)](https://github.com/appium/ruby_lib_core/actions/workflows/unittest.yml)
[![Functional Tests](https://github.com/appium/ruby_lib_core/actions/workflows/functional-test.yml/badge.svg)](https://github.com/appium/ruby_lib_core/actions/workflows/functional-test.yml)


This library is a Ruby client for Appium.  The gem is available via [appium_lib_core](https://rubygems.org/gems/appium_lib_core).

This library wraps [selenium-webdriver](https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings) and adapts WebDriver APIs for Appium. [ruby_lib](https://github.com/appium/ruby_lib) calls all of Appium/Selenium related APIs via this core library. It works instance based driver.

# Documentation

- https://www.rubydoc.info/gems/appium_lib_core
    - You can find working API examples in test code, [test/functional](test/functional)
- Appium 2.0
    - https://appium.github.io/appium/docs/en/2.0/ (Not completed yet)

# Migration from v4 to v5

Please read [`[5.0.0]`](CHANGELOG.md#500---2021-11-05) section in [CHANGELOG](CHANGELOG.md)

# Related library
- https://github.com/appium/ruby_lib

# How to start
## Run tests
### Unit Tests
Run unit tests which check each method and command, URL, using the webmock.

```bash
$ bundle install
$ bundle exec parallel_test test/unit/
```

or

```bash
$ bundle install
$ bundle exec rake test:unit
```

### Functional Tests
Run functional tests which require the Appium server and real device, Simulator/Emulator.

- Start Appium server (Appium 2.0 base)
```bash
$ npm install --location=global appium
$ appium driver install xcuitest
$ appium driver install uiautomator2 # etc
$ appium --relaxed-security # To run all tests in local
```

- Conduct tests
```bash
$ bundle install
$ rake test:func:android # Andorid, uiautomator2
$ APPIUM_DRIVER=espresso rake test:func:android # Andorid, uiautomator2
$ rake test:func:ios     # iOS
```

#### Real device for iOS

- You should pre-install [UICatalog](https://github.com/appium/ios-uicatalog) in iOS with a particular `bundleId`
    - Set the `bundleId` instead of `app` in `test/test_helper#ios`

```bash
# Create derivedDataPath in "/tmp/#{org_id}" and reuse xctestrun in the directory
$ REAL=true BUNDLE_ID='target-bundleid' WDA_BUNDLEID="ios.appium.WebDriverAgentRunner" ORG_ID=XXXXXXX rake test:func:ios

# Run with xcconfig file. The template is in 'test/functional/ios/temp.xcconfig'
# The PROVISIONING_PROFILE is in '~/Library/MobileDevice/Provisioning\ Profiles/'
$ REAL=true XCODE_CONFIG_FILE='/path/to/xcconfig' ORG_ID=XXXXXXX rake test:func:ios
```

#### Run parallel tests with parallel_tests gem
#### Android

```
# Generate 3 emulators. Running 3 emulators require much machine power.
# It requires an image which is for Google Play and x86 CPU architecture's image.
$ bundle exec rake android:gen_device
$ PARALLEL=1 bundle exec parallel_test test/functional/android -n 3
```

##### iOS
- Create iPhone simulators named `iPhone Xs Max- 8100` and `iPhone Xs Max - 8101`
- Run iOS functional tests with below command

```
$ PARALLEL=1 bundle exec parallel_test test/functional/ios -n 2
```

## CI

- Runs on CI environment (on Azure)
    - Non `IGNORE_VERSION_SKIP` or `IGNORE_VERSION_SKIP=true` runs all tests ignoring `skip` them by Appium versions
    - `IGNORE_VERSION_SKIP=false` skips the following tests if the Appium version is lower than the requirement

```
$ IGNORE_VERSION_SKIP=true CI=true bundle exec rake test:func:android
```

## Run a test case
1. Launch the Appium server locally.
2. Run the following script.

- `test.rb`
    ```ruby
    require 'rubygems'
    require 'appium_lib_core'

opts = {
  capabilities: { # Append capabilities
    platformName: 'android',
    platformVersion: '16',
    deviceName: 'Android',
    browserName: "chrome",
    # app: '/path/to/MyiOS.app',  # Without 'app' capability, an appium session starts with the home screen
    automationName: 'uiautomator2',
    udid: "emulator-5554",
    recreateChromeDriverSessions: true,
  },
  appium_lib: {
    wait: 30
  }
}
@core = Appium::Core.for(opts) # create a core driver with `opts`
@driver = @core.start_driver

    # Launch iPhone Simulator and `MyiOS.app`
    @driver.find_element(:accessibility_id, 'some accessibility') # find an element
    ```
- Run the script
    ```bash
    # shell 1
    $ appium --log-level warn:error # show only warning and error logs

    # shell 2
    $ ruby test.rb
    ```

[Appium::Core.for](https://rubydoc.info/github/appium/ruby_lib_core/Appium/Core/Driver#for-class_method) documentation has more example to build a new driver instance.

More examples are in [test/functional](test/functional)

As of version 5.8.0, the client can attach to an existing session. The main purpose is for debugging.

```ruby
# @driver is the driver instance of an existing session
attached_driver = ::Appium::Core::Driver.attach_to @driver.session_id, url: 'http://127.0.0.1:4723', automation_name: 'XCUITest', platform_name: 'ios'
assert attached_driver.session_id == @driver.session_id
attached_driver.page_source
```

### Capabilities

Read [Appium/Core/Driver](https://rubydoc.info/github/appium/ruby_lib_core/Appium/Core/Driver) to catch up with available capabilities.
Capabilities affect only ruby_lib is [Appium/Core/Options](https://rubydoc.info/github/appium/ruby_lib_core/Appium/Core/Options).

### Improvement ideas

- for iOS

```
$ appium driver run xcuitest download-wda-sim --outdir=/path/to/download/prebuilt/wda/
```

Then, adding capabilities below:

```json
{
  "appium:usePreinstalledWDA": true,
  "appium:prebuiltWDAPath": "/path/to/download/prebuilt/wda/WebDriverAgentRunner-Runner.app"
}
```

It will improve initial new session request performance for iOS simulator.

`"appium:settings[respectSystemAlerts]" => true` for capability will also help to work with [permissions](https://appium.github.io/appium-xcuitest-driver/latest/guides/troubleshooting/#interact-with-dialogs-managed-by-comapplespringboard).

### Gives custom listener

An example to define a customer listener with [Selenium::WebDriver::Support::AbstractEventListener](https://www.selenium.dev/selenium/docs/api/rb/Selenium/WebDriver/Support/AbstractEventListener.html)

```ruby
class CustomListener < ::Selenium::WebDriver::Support::AbstractEventListener
  // something
end
capabilities: {
  platformName: :ios,
  platformVersion: '11.0',
  deviceName: 'iPhone Simulator',
  automationName: 'XCUITest',
  app: '/path/to/MyiOS.app'
}
appium_lib: {
  listener: CustomListener.new
}
@core = Appium::Core.for capabilities: capabilities, appium_lib: appium_lib
@core.start_driver
```

# Development
- Demo app
    - https://android.googlesource.com/platform/development/+/master/samples/ApiDemos

# Release
Use [appium_thor](https://github.com/appium/appium_thor) to release this gem.

```bash
$ thor bump # bumpy,
$ thor release
```

# Contribution
1. Fork it ( https://github.com/appium/ruby_lib_core/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

# License
Apache License v2
