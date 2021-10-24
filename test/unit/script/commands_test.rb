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
require './script/commands'

class ScriptTest
  class CommandsCheckerTest < Minitest::Test
    def setup
      @c = Script::CommandsChecker.new
    end

    def test_get_all_command_path
      @c.get_all_command_path AppiumLibCoreTest.path_of('test/unit/script/test_routes.js')
      assert_equal 143, @c.spec_commands.length
      assert_equal ['status', [:get]], @c.spec_commands.first
      assert_equal %i(get post delete), @c.spec_commands['session/:session_id/cookie']

      assert_equal [:get], @c.spec_commands['session/:session_id/element/:id']
      assert_equal %i(get post), @c.spec_commands['session/:session_id/window/:window_handle/size']
      assert_equal [:get], @c.spec_commands['session/:session_id/element/:id/equals/:other']
      assert_equal [:get], @c.spec_commands['session/:session_id/element/:id/css/:property_name']
      assert_equal [:get], @c.spec_commands['session/:session_id/element/:id/page_index']
    end

    def test_implemented_core_commands
      assert_equal ['status', [:get]], @c.implemented_core_commands.first

      # pick up an arbitrary command
      assert_equal [:post], @c.implemented_core_commands['session/:session_id/appium/device/pull_folder']
    end

    def test_compare_commands_command1_is_bigger
      command1 = { 'session/:session_id/contexts' => [:get] }
      command2 = { 'session/:session_id/contexts' => %i(get post) }

      assert_equal({}, @c.compare_commands(command1, command2))
    end

    def test_compare_commands_command2_lack_some_commands
      command1 = { 'session/:session_id/contexts' => %i(get post) }
      command2 = { 'session/:session_id/contexts' => [:get] }

      assert_equal({ 'session/:session_id/contexts' => [:post] }, @c.compare_commands(command1, command2))
    end

    def test_can_call_diff_methods
      assert_equal({}, @c.diff_except_for_webdriver)
    end
  end
end
