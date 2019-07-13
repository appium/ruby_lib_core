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

require_relative 'wait/timer'

module Appium
  module Core
    module Wait
      class TimeoutError < StandardError; end

      DEFAULT_TIMEOUT  = 30
      DEFAULT_INTERVAL = 0.5

      class << self
        # Check every interval seconds to see if yield doesn't raise an exception.
        # Give up after timeout seconds.
        #
        # If only a number is provided then it's treated as the timeout value.
        #
        # @param [Integer] timeout Seconds to wait before timing out. Set default by +appium_wait_timeout+ (30).
        # @param [Integer] interval Seconds to sleep between polls. Set default by +appium_wait_interval+ (0.5).
        # @param [String] message Exception message if timed out.
        # @param [Array, Exception] ignored Exceptions to ignore while polling (default: Exception)
        # @param [Object, NilClass] object Object to evaluate block against
        #
        # @example
        #
        #     result = Appium::Core::Wait.until { @driver.find_element(:id, 'something') }
        #
        #     result = Appium::Core::Wait.until(object: 'some object') { |object|
        #        @driver.find_element(:id, object)
        #     }
        #
        def until(timeout: DEFAULT_TIMEOUT, interval: DEFAULT_INTERVAL, message: nil, ignored: nil, object: nil)
          ignored = Array(ignored || ::Exception)

          last_error = nil
          timer = Wait::Timer.new(timeout)

          until timer.timeout?
            begin
              return yield(object)
            rescue ::Errno::ECONNREFUSED => e
              raise e
            rescue *ignored => last_error # rubocop:disable Lint/HandleExceptions
              # swallowed
            end
            sleep interval
          end

          msg = message_for timeout, message
          msg += " (#{last_error.message})" if last_error

          raise TimeoutError, msg
        end

        # Check every interval seconds to see if yield returns a truthy value.
        # Note this isn't a strict boolean true, any truthy value is accepted.
        # false and nil are considered failures.
        # Give up after timeout seconds.
        #
        # If only a number is provided then it's treated as the timeout value.
        #
        # @param [Integer] timeout Seconds to wait before timing out. Set default by +appium_wait_timeout+ (30).
        # @param [Integer] interval Seconds to sleep between polls. Set default by +appium_wait_interval+ (0.5).
        # @param [String] message Exception message if timed out.
        # @param [Array, Exception] ignored Exceptions to ignore while polling (default: Exception)
        # @param [Object, NilClass] object Object to evaluate block against
        #
        # @example
        #
        #     Appium::Core::Wait.until_true { @driver.find_element(:id, 'something') }
        #
        #     Appium::Core::Wait.until_true(object: 'some object') { |object|
        #        @driver.find_element(:id, object)
        #     }
        #
        def until_true(timeout: DEFAULT_TIMEOUT, interval: DEFAULT_INTERVAL, message: nil, ignored: nil, object: nil)
          ignored = Array(ignored || ::Exception)

          last_error = nil
          timer = Wait::Timer.new(timeout)

          until timer.timeout?
            begin
              result = yield(object)
              return result if result
            rescue ::Errno::ECONNREFUSED => e
              raise e
            rescue *ignored => last_error # rubocop:disable Lint/HandleExceptions
              # swallowed
            end
            sleep interval
          end

          msg = message_for timeout, message
          msg += " (#{last_error.message})" if last_error

          raise TimeoutError, msg
        end

        private

        def message_for(timeout, message)
          msg = "timed out after #{timeout} seconds"
          msg += ", #{message}" if message
          msg
        end
      end # self
    end # module Wait

    module Waitable
      # Check every interval seconds to see if yield returns a truthy value.
      # Note this isn't a strict boolean true, any truthy value is accepted.
      # false and nil are considered failures.
      # Give up after timeout seconds.
      #
      # If only a number is provided then it's treated as the timeout value.
      #
      # @param [Integer] timeout Seconds to wait before timing out. Set default by +appium_wait_timeout+ (30).
      # @param [Integer] interval Seconds to sleep between polls. Set default by +appium_wait_interval+ (0.5).
      # @param [String] message Exception message if timed out.
      # @param [Array, Exception] ignored Exceptions to ignore while polling (default: Exception)
      #
      # @example
      #
      #   @core.wait_true { @driver.find_element :accessibility_id, 'something' }
      #
      def wait_true(timeout: nil, interval: nil, message: nil, ignored: nil)
        Wait.until_true(timeout: timeout || @wait_timeout,
                        interval: interval || @wait_interval,
                        message: message,
                        ignored: ignored,
                        object: self) { yield }
      end

      # Check every interval seconds to see if yield doesn't raise an exception.
      # Give up after timeout seconds.
      #
      # If only a number is provided then it's treated as the timeout value.
      #
      # @param [Integer] timeout Seconds to wait before timing out. Set default by +appium_wait_timeout+ (30).
      # @param [Integer] interval Seconds to sleep between polls. Set default by +appium_wait_interval+ (0.5).
      # @param [String] message Exception message if timed out.
      # @param [Array, Exception] ignored Exceptions to ignore while polling (default: Exception)
      #
      # @example
      #
      #   @core.wait { @driver.find_element :accessibility_id, 'something' }
      #
      def wait(timeout: nil, interval: nil, message: nil, ignored: nil)
        Wait.until(timeout: timeout || @wait_timeout,
                   interval: interval || @wait_interval,
                   message: message,
                   ignored: ignored,
                   object: self) { yield }
      end
    end
  end # module Core
end # module Appium
