# Mobile Command

Appium has `mobile:` command.
We can invoke them via `execute_script` command with `mobile:` arguments.

- root:
    - https://github.com/appium/appium/blob/master/commands-yml/commands/mobile-command.yml
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

Mobile commands return their error messages. As a selenium client, it usually handles as unknown error.
To handle it, we would recommend you to handle the error based on the error message.

```ruby
error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
  _, element_id = el.ref
  @driver.execute_script 'mobile: scrollToPage', { element: element_id, scrollToPage: -100 }
end
assert error.message.include? 'be a non-negative integer'
```
