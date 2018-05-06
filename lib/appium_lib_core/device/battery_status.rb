module Appium
  module Core
    module Device
      module BatteryStatus
        ANDROID = [
          :undefined,    # 0, dummy
          :unknown,      # 1
          :charging,     # 2
          :discharging,  # 3
          :not_charging, # 4
          :full          # 5
        ].freeze

        IOS = [
          :unknown,      # 0
          :unplugged,    # 1
          :charging,     # 2
          :full          # 3
        ].freeze
      end
    end
  end
end
