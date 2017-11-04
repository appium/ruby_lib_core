# AppiumLibCore

[![Gem Version](https://badge.fury.io/rb/appium_lib_core.svg)](https://badge.fury.io/rb/appium_lib_core)

# Documentation

- http://www.rubydoc.info/github/appium/ruby_lib_core

# base library
- https://github.com/appium/ruby_lib

# How to start
## Start Appium server

```bash
$ npm install -g appium
$ appium
```

## Run tests

```bash
$ bundle install
$ rake test:func:android # Andorid
$ rake test:func:ios     # iOS
```

# Release

```bash
$ bundle exec thor bump # bumpy, bumpz
$ bundle exec thor release
```

# License
Apache License v2
