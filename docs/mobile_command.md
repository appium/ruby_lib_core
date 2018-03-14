# Mobile Command

Appium has `mobile:` command.
They call via `execute_script` command with `mobile:` arguments.

- Android:
    - https://github.com/appium/appium/blob/master/docs/en/writing-running-appium/android
- iOS:
    - https://github.com/appium/appium/tree/master/docs/en/writing-running-appium/ios
    

```ruby
# Android shell : https://github.com/appium/appium/blob/master/docs/en/writing-running-appium/android/android-shell.md
args = { command: 'echo', args: 'list' }
@driver.execute_script 'mobile: shell', args # Run `adb shell echo 'list'`

# iOS performance : https://github.com/appium/appium/blob/master/docs/en/writing-running-appium/ios/ios-xctest-performance.md
args = { timeout: 60 * 1000, profileName: 'Activity Monitor' }
@driver.execute_script 'mobile: startPerfRecord', args

@driver.execute_script 'mobile: stopPerfRecord', { profileName: 'Activity Monitor' }
```
