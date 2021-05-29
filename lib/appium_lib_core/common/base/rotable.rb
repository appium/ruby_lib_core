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

module Appium
  module Core
    class Base
      #
      # @api private
      #

      module Rotatable
        ORIENTATIONS = %i[landscape portrait].freeze

        #
        # Change the screen orientation
        #
        # @param [:landscape, :portrait] orientation
        #
        #
        def rotation=(orientation)
          unless ORIENTATIONS.include?(orientation)
            raise ::Appium::Core::Error::ArgumentError, "expected #{ORIENTATIONS.inspect}, got #{orientation.inspect}"
          end

          bridge.screen_orientation = orientation.to_s.upcase
        end
        alias rotate rotation=

        #
        # Get the current screen orientation
        #
        # @return [:landscape, :portrait] orientation
        #
        # @api public
        #

        def orientation
          bridge.screen_orientation.to_sym.downcase
        end
      end
    end
  end
end
