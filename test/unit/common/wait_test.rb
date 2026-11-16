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

require 'test_helper'

class AppiumLibCoreTest
  class WaitTest < Minitest::Test
    def test_missing_elements_are_retried_by_default
      %i[until until_true].each do |method|
        calls = 0
        result = Appium::Core::Wait.public_send(method, timeout: 1, interval: 0) do
          calls += 1
          raise Selenium::WebDriver::Error::NoSuchElementError, 'not ready' if calls == 1

          :found
        end
        assert_equal :found, result
        assert_equal 2, calls
      end
    end

    def test_other_errors_propagate_without_retry
      %i[until until_true].each do |method|
        [NoMethodError.new('typo'), RuntimeError.new('failure'), Interrupt.new,
         SystemExit.new, Selenium::WebDriver::Error::InvalidSessionIdError.new('closed')].each do |error|
          calls = 0
          actual = assert_raises(error.class) do
            Appium::Core::Wait.public_send(method, timeout: 0.01, interval: 0) do
              calls += 1
              raise error
            end
          end
          assert_same error, actual
          assert_equal 1, calls
        end
      end
    end

    def test_explicit_ignored_errors_are_retried
      %i[until until_true].each do |method|
        [RuntimeError, [RuntimeError]].each do |ignored|
          calls = 0
          result = Appium::Core::Wait.public_send(method, timeout: 1, interval: 0, ignored: ignored) do
            calls += 1
            raise 'not ready' if calls == 1

            :ready
          end
          assert_equal :ready, result
          assert_equal 2, calls
        end
      end
    end

    def test_explicit_empty_list_disables_default_retry
      %i[until until_true].each do |method|
        calls = 0
        assert_raises(Selenium::WebDriver::Error::NoSuchElementError) do
          Appium::Core::Wait.public_send(method, timeout: 0.01, interval: 0, ignored: []) do
            calls += 1
            raise Selenium::WebDriver::Error::NoSuchElementError
          end
        end
        assert_equal 1, calls
      end
    end

    def test_timeout_keeps_the_last_missing_element_error
      %i[until until_true].each do |method|
        error = assert_raises(Appium::Core::Wait::TimeoutError) do
          Appium::Core::Wait.public_send(method, timeout: 0.01, interval: 0, message: 'waiting for button') do
            raise Selenium::WebDriver::Error::NoSuchElementError, 'button missing'
          end
        end
        assert_match(/waiting for button/, error.message)
        assert_match(/button missing/, error.message)
      end
    end

    def test_success_conditions_are_unchanged
      assert_nil Appium::Core::Wait.until(timeout: 1) { nil }
      assert_equal false, Appium::Core::Wait.until(timeout: 1) { false }
      values = [nil, false, :ready]
      assert_equal :ready, Appium::Core::Wait.until_true(timeout: 1, interval: 0) { values.shift }
      assert_empty values
    end

    def test_connection_refused_is_never_retried_even_when_explicitly_ignored
      %i[until until_true].each do |method|
        calls = 0
        assert_raises(Errno::ECONNREFUSED) do
          Appium::Core::Wait.public_send(method, timeout: 0.01, interval: 0, ignored: Exception) do
            calls += 1
            raise Errno::ECONNREFUSED
          end
        end
        assert_equal 1, calls
      end
    end

    def test_waitable_aliases_use_the_new_default
      core = Appium::Core.for(Caps.android)
      %i[wait wait_until wait_true wait_until_true].each do |method|
        calls = 0
        assert_raises(NoMethodError) do
          core.public_send(method, timeout: 0.01, interval: 0) do
            calls += 1
            raise NoMethodError, 'typo'
          end
        end
        assert_equal 1, calls
      end
    end
  end
end
