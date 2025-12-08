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
      module HasLocation
        # Get the location of the device.
        #
        # @return [::Appium::Location]
        #
        # @example
        #
        #   driver.location #=> ::Appium::Location.new(10, 10, 10)
        #
        def location
          @bridge.location
        end

        # Set the location of the device.
        #
        # @param [::Appium::Location] location Set the location.
        #
        # @example
        #
        #   driver.location = ::Appium::Location.new(10, 10, 10)
        #
        def location=(location)
          raise TypeError, "expected #{::Appium::Location}, got #{location.inspect}:#{location.class}" unless location.is_a?(::Appium::Location)

          @bridge.set_location location.latitude, location.longitude, location.altitude
        end

        # Set the location of the device.
        #
        # @param [String, Number] latitude Set the latitude.
        # @param [String, Number] longitude Set the longitude.
        # @param [String, Number] altitude Set the altitude.
        # @param [String, Number] speed Set the speed to apply the location on Android real devices
        #                               in meters/second @since Appium 1.21.0 and in knots for emulators @since Appium 1.22.0.
        # @param [String, Number] satellites Sets the count of geo satellites being tracked in range 1..12 @since Appium 1.22.0.
        #                                    This number is respected on Emulators.
        #
        # @example
        #
        #   driver.location = ::Appium::Location.new(10, 10, 10)
        #
        def set_location(latitude, longitude, altitude, speed: nil, satellites: nil)
          if speed.nil? && satellites.nil?
            self.location = ::Appium::Location.new(Float(latitude), Float(longitude), Float(altitude))
          else
            loc = ::Appium::Location.new(Float(latitude), Float(longitude), Float(altitude))

            speed = Float(speed) unless speed.nil?
            satellites = Integer(satellites) unless satellites.nil?

            @bridge.set_location loc.latitude, loc.longitude, loc.altitude, speed: speed, satellites: satellites
          end
        end
      end
    end
  end
end
