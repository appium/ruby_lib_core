module Appium
  module Core
    module Android
      module Uiautomator2
        module Bridge
          def self.for(target)
            target.extend Appium::Android::Device
            Core::Android::SearchContext.extend
          end
        end
      end
    end
  end
end
