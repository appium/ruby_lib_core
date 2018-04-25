require 'test_helper'

class AppiumLibCoreTest
  class TimterTest < Minitest::Test
    def test_timer
      timeout = 0.3

      timer = ::Appium::Core::Wait::Timer.new(timeout)
      start = timer.current_time

      count = 0
      until timer.timeout?
        count += 1
        sleep 0.1
      end

      assert_equal 3, count
      assert timeout <= timer.current_time - start
    end
  end
end
