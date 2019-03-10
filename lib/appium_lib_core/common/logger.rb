# frozen_string_literal: true

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'forwardable'
require 'logger'

module Appium
  module Logger
    #
    # @example Use logger manually
    #   Appium::Logger.debug('This is info message')
    #   Appium::Logger.warn('This is warning message')
    #
    class << self
      extend Forwardable
      def_delegators :logger, :fatal, :error, :warn, :info, :debug, :level, :level=, :formatter, :formatter=

      attr_writer :logger

      private

      def logger
        @logger ||= begin
          logger = ::Logger.new($stdout)
          logger.progname = 'ruby_lib'
          logger.level = ::Logger::WARN
          logger.formatter = proc { |_severity, _datetime, _progname, msg| "#{msg}\n" }
          logger
        end
      end
    end # class << self
  end # module Logger
end # module Appium
