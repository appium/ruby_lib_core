# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
### Enhancements

### Bug fixes

### Deprecations

## [1.4.1] - 2018-04-22
### Enhancements
- add base image comparison
    - `match_images_features`, `find_image_occurrence`, `get_images_similarity`, `compare_images`
- [internal] No longer have dependency for Selenium's wait
- [internal] Separate mjsonwp commands module and w3c commands module from one command module

### Bug fixes

### Deprecations

## [1.4.0] - 2018-04-15
### Enhancements
- Add a support for WebSocket client based on Faye::WebSocket::Client [#74](https://github.com/appium/ruby_lib_core/pull/74)

### Bug fixes

### Deprecations

## [1.3.8] - 2018-04-12
### Enhancements
- Make no-argument commands friendly for IDE

### Bug fixes

### Deprecations

## [1.3.7] - 2018-04-02
### Enhancements
- Only for `ruby_lib_core` internal process
    - Remove `touch` action by default and following `selenium-webdriver` in W3C action.
        - Since XCUITest and UA2 drivers force handling the pointer as `touch`.

### Bug fixes

### Deprecations

## [1.3.6] - 2018-04-01
### Enhancements
- Be able to change `kind` in W3C touch action.
    - Read: https://github.com/appium/ruby_lib_core/blob/master/lib/appium_lib_core/common/base/bridge/w3c.rb#L29

### Bug fixes

### Deprecations

## [1.3.5] - 2018-03-30
### Enhancements
- Add a `bug_report` option in `start_recording_screen`, Android
- Add clipboard apis [#69](https://github.com/appium/ruby_lib_core/pull/69)

### Bug fixes

### Deprecations

## [1.3.4] - 2018-03-21
### Enhancements
- Add `save_viewport_screenshot` which get screenshot except for status bar. 
    - https://github.com/search?q=org%3Aappium+viewportScreenshot&type=Code
- [iOS] Add `start_performance_record` and `get_performance_record`

### Bug fixes
- Fix _create_session attempt to throw non-existent error type Appium::Core::Error::WebDriverError_ [#66](https://github.com/appium/ruby_lib_core/issues/66)

### Deprecations

## [1.3.3] - 2018-03-03
### Enhancements
- add `session_capabilities`: https://appium.io/docs/en/commands/session/get/

### Bug fixes

### Deprecations

## [1.3.2] - 2018-02-18
### Enhancements
- Add Android emulator commands
    - `send_sms`, `gsm_call`, `gsm_signal`, `gsm_voice`, `set_network_speed`, `set_power_capacity`, `set_power_ac`
- Add toggles
    - `toggle_location_services`, `toggle_wifi`, `toggle_data`

### Bug fixes

### Deprecations

## [1.3.1] - 2018-02-14
### Enhancements
- add some app management commands [#58](https://github.com/appium/ruby_lib_core/pull/58)
    - Require Appium 1.8.0+
- Both platforms work absolute based axis for `move_to` and `swipe`
    - **Breaking Changes**
        - Android was relevant, previously.
        - e.g.:
            ```ruby
            # Do not move because of the start and end point is the same
            # Tap (75, 500) and move the point to (75, 500) with duration 500ms.
            Appium::Core::TouchAction.new(@driver)
              .swipe(start_x: 75, start_y: 500, offset_x: 75, offset_y: 500, duration: 500)
              .perform
        
            # Tap (75, 500) and move the point to (75, 1000) with duration 500ms.
            Appium::Core::TouchAction.new(@driver)
              .swipe(start_x: 75, start_y: 500, offset_x: 75, offset_y: 1000, duration: 500)
              .perform
            ```

### Bug fixes

### Deprecations

## [1.3.0] - 2018-01-28
### Enhancements
- `start_recording_screen`/`stop_recording_screen` support iOS from `Appium 1.8.0` [#48](https://github.com/appium/ruby_lib_core/issues/48)
    - **Breaking Changes**
        - `start_recording_screen`
            - The argument, `file_path`, was removed.

### Bug fixes

### Deprecations

## [1.2.7] - 2018-01-25
### Enhancements
- Print warning messages to use camelCase if capability key names are snake_case
    - For W3C adaption for Appium Server

### Bug fixes
- Make `@driver.automation_name` downcase [#50](https://github.com/appium/ruby_lib_core/issues/50)

### Deprecations

## [1.2.6] - 2018-01-21
### Enhancements
- Add `window_rect`

### Bug fixes
- Make `@driver.automation_name` symbol when someone define the `automationName` with the server argument. [#50](https://github.com/appium/ruby_lib_core/issues/50)

### Deprecations

## [1.2.5] - 2018-01-13
### Enhancements
- Enhance W3C support
    - Timeout related methods

### Bug fixes

### Deprecations

## [1.2.4] - 2018-01-03
### Enhancements
- Refactor `create_session` in `Appium::Core::Base::Bridge`
- Be able to communicate with Appium by `W3C` based webdriver protocol if the Appium supports W3C protocol.
    - If `forceMjsonwp: true` exists in the capability, the client try to communicate `mjsonwp` based protocol
        - By default, it depends on the response from the server
    - Read API doc for `Appium::Core::Base::Bridge#create_session` to read the example of `forceMjsonwp`
- Backport some commands from OSS module to W3C module
    - Read `lib/appium_lib_core/common/base/w3c_bridge.rb` for more details
- Can get logs like `driver.logs.available_types` and `driver.logs.get`

### Bug fixes

### Deprecations

## [1.2.3] - 2017-12-27
### Enhancements

### Bug fixes
- Fix some w3c methods to work with Appium part 2 [#38](https://github.com/appium/ruby_lib_core/pull/38)

### Deprecations

## [1.2.2] - 2017-12-25
### Enhancements

### Bug fixes
- Fix some w3c methods to work with Appium [#37](https://github.com/appium/ruby_lib_core/pull/37)

### Deprecations

## [1.2.1] - 2017-12-23
### Enhancements
- override default duration to make some action fast [#36](https://github.com/appium/ruby_lib_core/pull/36)

### Bug fixes

### Deprecations

## [1.2.0] - 2017-12-23
### Enhancements
- Append `appium:` prefix for capabilities automatically due to W3C format.
- add take element screenshot for oss module [#33](https://github.com/appium/ruby_lib_core/pull/33)
- add w3c touch action tests and some supports for w3c [#35](https://github.com/appium/ruby_lib_core/pull/35)
    - IME related
    - Touch actions based on W3C spec

### Bug fixes

### Deprecations

## [1.1.0] - 2017-12-16
### Enhancements
- Add guidelines in `.github`
- session/:session_id/appium/device/keyevent [#21](https://github.com/appium/ruby_lib_core/issues/21)

### Bug fixes
- fix creating sessions [#31](https://github.com/appium/ruby_lib_core/pull/31) for W3C creating sessions

### Deprecations

## [1.0.0] - 2017-11-12

Initial release
