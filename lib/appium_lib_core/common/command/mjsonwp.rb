# rubocop:disable Layout/AlignHash
module Appium
  module Core
    module Commands
      module MJSONWP
        COMMANDS = ::Appium::Core::Commands::COMMANDS.merge(::Appium::Core::Base::Commands::OSS).merge(
          {
            # W3C already has.
            take_element_screenshot:    [:get, 'session/:session_id/element/:id/screenshot'.freeze]
          }
        ).freeze
      end # module MJSONWP
    end # module Commands
  end # module Core
end # Appium
# rubocop:enable Layout/AlignHash
