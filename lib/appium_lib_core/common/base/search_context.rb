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

EXTRA_FINDERS = {
  accessibility_id:     'accessibility id',
  image:                '-image',
  custom:               '-custom',
  # Android
  uiautomator:          '-android uiautomator', # Unavailable in Espresso
  viewtag:              '-android viewtag',     # Available in Espresso
  data_matcher:         '-android datamatcher', # Available in Espresso
  view_matcher:         '-android viewmatcher', # Available in Espresso
  # iOS
  predicate:            '-ios predicate string',
  class_chain:          '-ios class chain'
}.freeze
