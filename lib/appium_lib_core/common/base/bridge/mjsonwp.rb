module Appium
  module Core
    class Base
      class Bridge
        class MJSONWP < ::Selenium::WebDriver::Remote::OSS::Bridge
          include ::Appium::Core::Base::Device::DeviceLock
          include ::Appium::Core::Base::Device::Keyboard
          include ::Appium::Core::Base::Device::ImeActions
          include ::Appium::Core::Base::Device::Setting
          include ::Appium::Core::Base::Device::Context
          include ::Appium::Core::Base::Device::Value
          include ::Appium::Core::Base::Device::FileManagement
          include ::Appium::Core::Base::Device::KeyEvent
          include ::Appium::Core::Base::Device::ImageComparison
          include ::Appium::Core::Base::Device::AppManagement
          include ::Appium::Core::Base::Device::AppState

          def commands(command)
            ::Appium::Core::Commands::MJSONWP::COMMANDS[command]
          end

          #
          # @return [::Appium::Core::ImageElement|nil]
          # @raise [::Selenium::WebDriver::Error::TimeOutError|::Selenium::WebDriver::Error::WebDriverError]
          #
          def find_element_by_image(full_image:, partial_image:, match_threshold: nil, visualize: false)
            options = {}
            options[:threshold] = match_threshold unless match_threshold.nil?
            options[:visualize] = visualize

            params = {}
            params[:mode] = :matchTemplate
            params[:firstImage] = full_image
            params[:secondImage] = partial_image
            params[:options] = options if options

            result = execute(:compare_images, {}, params)
            rect = result['rect']

            if rect
              return ::Appium::Core::ImageElement.new(self,
                                                      rect['x'],
                                                      rect['y'],
                                                      rect['width'],
                                                      rect['height'],
                                                      result['visualization'])
            end
            nil
          end

          #
          # @return [[]|[::Appium::Core::ImageElement]]
          # @raise [::Selenium::WebDriver::Error::TimeOutError|::Selenium::WebDriver::Error::WebDriverError]
          #
          def find_elements_by_image(full_image:, partial_images:, match_threshold: nil, visualize: false)
            options = {}
            options[:threshold] = match_threshold unless match_threshold.nil?
            options[:visualize] = visualize

            params = {}
            params[:mode] = :matchTemplate
            params[:firstImage] = full_image
            params[:options] = options if options

            partial_images.each_with_object([]) do |partial_image, acc|
              params[:secondImage] = partial_image

              begin
                result = execute(:compare_images, {}, params)
                rect = result['rect']

                if result['rect']
                  acc.push ::Appium::Core::ImageElement.new(self,
                                                            rect['x'],
                                                            rect['y'],
                                                            rect['width'],
                                                            rect['height'],
                                                            result['visualization'])
                end
              rescue ::Selenium::WebDriver::Error::WebDriverError => e
                acc if e.message.include?('Cannot find any occurrences')
              end
            end
          end

          def take_element_screenshot(element)
            execute :take_element_screenshot, id: element.ref
          end
        end # class MJSONWP
      end # class Bridge
    end # class Base
  end # module Core
end # module Appium
