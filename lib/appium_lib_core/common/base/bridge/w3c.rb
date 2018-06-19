require 'base64'

module Appium
  module Core
    class Base
      class Bridge
        class W3C < ::Selenium::WebDriver::Remote::W3C::Bridge
          # Used for default duration of each touch actions
          # Override from 250 milliseconds to 50 milliseconds
          ::Selenium::WebDriver::PointerActions::DEFAULT_MOVE_DURATION = 0.05

          def commands(command)
            ::Appium::Core::Commands::W3C::COMMANDS[command]
          end

          # Perform touch actions for W3C module.
          # Generate `touch` pointer action here and users can use this via `driver.action`
          # - https://seleniumhq.github.io/selenium/docs/api/rb/Selenium/WebDriver/W3CActionBuilder.html
          # - https://seleniumhq.github.io/selenium/docs/api/rb/Selenium/WebDriver/PointerActions.html
          # - https://seleniumhq.github.io/selenium/docs/api/rb/Selenium/WebDriver/KeyActions.html
          #
          # 'mouse' action is by default in the Ruby client. Appium server force the `mouse` action to `touch` once in
          # the server side. So we don't consider the case.
          #
          # @example
          #
          #     element = @driver.find_element(:id, "some id")
          #     @driver.action.click(element).perform # The `click` is a part of `PointerActions`
          #
          #     # You can change the kind as the below.
          #     @driver.action(kind: :mouse).click(element).perform # The `click` is a part of `PointerActions`
          #

          # Port from MJSONWP
          def get_timeouts
            execute :get_timeouts
          end

          # Port from MJSONWP
          def session_capabilities
            ::Selenium::WebDriver::Remote::W3C::Capabilities.json_create execute(:get_capabilities)
          end

          # For Appium
          # override
          def page_source
            # For W3C
            # execute_script('var source = document.documentElement.outerHTML;' \
            # 'if (!source) { source = new XMLSerializer().serializeToString(document); }' \
            # 'return source;')
            execute :get_page_source
          end

          # For Appium
          # override
          def element_attribute(element, name)
            # For W3C
            # execute_atom :getAttribute, element, name
            execute :get_element_attribute, id: element.ref, name: name
          end

          # For Appium
          # override
          def find_element_by(how, what, parent = nil)
            how, what = convert_locators(how, what)

            id = if parent
                   execute :find_child_element, { id: parent }, { using: how, value: what }
                 else
                   execute :find_element, {}, { using: how, value: what }
                 end
            ::Selenium::WebDriver::Element.new self, element_id_from(id)
          end

          # For Appium
          # override
          def find_elements_by(how, what, parent = nil)
            how, what = convert_locators(how, what)

            ids = if parent
                    execute :find_child_elements, { id: parent }, { using: how, value: what }
                  else
                    execute :find_elements, {}, { using: how, value: what }
                  end

            ids.map { |id| ::Selenium::WebDriver::Element.new self, element_id_from(id) }
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

          # For Appium
          # override
          # called in `extend DriverExtensions::HasNetworkConnection`
          def network_connection
            execute :get_network_connection
          end

          # For Appium
          # override
          # called in `extend DriverExtensions::HasNetworkConnection`
          def network_connection=(type)
            execute :set_network_connection, {}, { parameters: { type: type } }
          end

          # For Appium
          # No implementation for W3C webdriver module
          # called in `extend DriverExtensions::HasLocation`
          def location
            obj = execute(:get_location) || {}
            ::Selenium::WebDriver::Location.new obj['latitude'], obj['longitude'], obj['altitude']
          end

          # For Appium
          # No implementation for W3C webdriver module
          # called in `extend DriverExtensions::HasLocation`
          def set_location(lat, lon, alt)
            loc = { latitude: lat, longitude: lon, altitude: alt }
            execute :set_location, {}, { location: loc }
          end

          #
          # logs
          #
          # For Appium
          # No implementation for W3C webdriver module
          def available_log_types
            types = execute :get_available_log_types
            Array(types).map(&:to_sym)
          end

          # For Appium
          # No implementation for W3C webdriver module
          def log(type)
            data = execute :get_log, {}, { type: type.to_s }

            Array(data).map do |l|
              begin
                ::Selenium::WebDriver::LogEntry.new l.fetch('level', 'UNKNOWN'), l.fetch('timestamp'), l.fetch('message')
              rescue KeyError
                next
              end
            end
          end

          private

          # Don't convert locators for Appium Client
          # TODO: Only for Appium. Ideally, we'd like to keep the selenium-webdriver
          def convert_locators(how, what)
            # case how
            # when 'class name'
            #   how = 'css selector'
            #   what = ".#{escape_css(what)}"
            # when 'id'
            #   how = 'css selector'
            #   what = "##{escape_css(what)}"
            # when 'name'
            #   how = 'css selector'
            #   what = "*[name='#{escape_css(what)}']"
            # when 'tag name'
            #   how = 'css selector'
            # end
            [how, what]
          end
        end # class W3C
      end # class Bridge
    end # class Base
  end # module Core
end # module Appium
