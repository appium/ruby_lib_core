module Appium
  module Core
    class Base
      class CoreBridgeW3C < ::Selenium::WebDriver::Remote::W3C::Bridge
        # Used for default duration of each touch actions
        # Override from 250 milliseconds to 50 milliseconds
        ::Selenium::WebDriver::PointerActions::DEFAULT_MOVE_DURATION = 0.05

        def commands(command)
          ::Appium::Core::Commands::COMMANDS_EXTEND_W3C[command]
        end

        # Perform touch actions for W3C module. Generate `touch` pointer action here and users can use this via `driver.action`
        # - https://seleniumhq.github.io/selenium/docs/api/rb/Selenium/WebDriver/W3CActionBuilder.html
        # - https://seleniumhq.github.io/selenium/docs/api/rb/Selenium/WebDriver/PointerActions.html
        # - https://seleniumhq.github.io/selenium/docs/api/rb/Selenium/WebDriver/KeyActions.html
        #
        # @private
        # override
        #
        # @example
        #
        #     element = @driver.find_element(:id, "some id")
        #     @driver.action.click(element).perform # The `click` is a part of `PointerActions`
        #
        def action(async = false)
          ::Selenium::WebDriver::W3CActionBuilder.new self,
                                                      ::Selenium::WebDriver::Interactions.pointer(:touch, name: 'touch'),
                                                      ::Selenium::WebDriver::Interactions.key('keyboard'),
                                                      async
        end
        alias actions action

        # override
        def page_source
          # For W3C
          # execute_script('var source = document.documentElement.outerHTML;' \
          # 'if (!source) { source = new XMLSerializer().serializeToString(document); }' \
          # 'return source;')
          execute :get_page_source
        end

        # override
        def element_attribute(element, name)
          # For W3C
          # execute_atom :getAttribute, element, name
          execute :get_element_attribute, id: element.ref, name: name
        end

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
      end # class CoreBridgeW3C
    end # class Base
  end # module Core
end # module Appium
