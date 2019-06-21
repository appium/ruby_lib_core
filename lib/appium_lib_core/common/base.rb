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

require_relative 'device/device_lock'
require_relative 'device/keyboard'
require_relative 'device/ime_actions'
require_relative 'device/setting'
require_relative 'device/context'
require_relative 'device/value'
require_relative 'device/file_management'
require_relative 'device/keyevent'
require_relative 'device/image_comparison'
require_relative 'device/app_management'
require_relative 'device/app_state'
require_relative 'device/screen_record'
require_relative 'device/battery_status'
require_relative 'device/clipboard_content_type'
require_relative 'device/device'
require_relative 'device/touch_actions'
require_relative 'device/execute_driver'

# The following files have selenium-webdriver related stuff.
require_relative 'base/driver'
require_relative 'base/bridge'
require_relative 'base/bridge/mjsonwp'
require_relative 'base/bridge/w3c'
require_relative 'base/capabilities'
require_relative 'base/http_default'
require_relative 'base/search_context'
require_relative 'base/command'
require_relative 'base/platform'
