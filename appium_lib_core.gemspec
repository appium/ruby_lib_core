require_relative 'lib/appium_lib_core/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1')

  spec.name          = 'appium_lib_core'
  spec.version       = Appium::Core::VERSION
  spec.authors       = ['Kazuaki MATSUO']
  spec.email         = ['fly.49.89.over@gmail.com']

  spec.summary       = 'Minimal Ruby library for Appium.'
  spec.description   = 'Core Ruby client for Appium, extending Selenium WebDriver with Appium-specific commands.'
  spec.homepage      = 'https://github.com/appium/ruby_lib_core/'
  spec.license       = 'Apache-2.0'
  spec.files         = Dir.glob(%w[lib/**/*.rb sig/**/*.rbs README.md LICENSE.txt CHANGELOG.md appium_lib_core.gemspec])
  spec.require_paths = ['lib']

  spec.add_dependency 'selenium-webdriver', '~> 4.21'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['bug_tracker_uri'] = 'https://github.com/appium/ruby_lib_core/issues'
  spec.metadata['changelog_uri'] = 'https://github.com/appium/ruby_lib_core/blob/master/CHANGELOG.md'
  spec.metadata['documentation_uri'] = 'https://www.rubydoc.info/gems/appium_lib_core'
end
