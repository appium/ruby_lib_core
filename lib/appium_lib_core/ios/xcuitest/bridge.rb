module Appium
  module Core
    module Ios
      module Xcuitest
        module Bridge
          def self.for(target)
            target.extend Appium::Core::Ios::Device
            target.extend Appium::Core::Ios::Xcuitest::Device
          end
        end
      end
    end
  end
end
