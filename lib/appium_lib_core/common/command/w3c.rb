module Appium
  module Core
    module Commands
      module W3C
        COMMANDS = ::Appium::Core::Commands::COMMANDS.merge(::Appium::Core::Base::Commands::W3C).merge(
          {
            # ::Appium::Core::Base::Commands::OSS has the following commands and Appium also use them.
            # Delegated to ::Appium::Core::Base::Commands::OSS commands
            status:                    [:get, 'status'.freeze],
            is_element_displayed:      [:get, 'session/:session_id/element/:id/displayed'.freeze],

            # FIXME: remove after apply https://github.com/SeleniumHQ/selenium/pull/5249
            # The fix will be included in selenium-3.8.2
            get_page_source:           [:get, 'session/:session_id/source'.freeze],

            get_timeouts:              [:get, 'session/:session_id/timeouts'.freeze],

            ## Add OSS commands to W3C commands. We can remove them if we would like to remove them from W3C module.
            ### Session capability
            get_capabilities:          [:get, 'session/:session_id'.freeze],

            ### rotatable
            get_screen_orientation:    [:get, 'session/:session_id/orientation'.freeze],
            set_screen_orientation:    [:post, 'session/:session_id/orientation'.freeze],

            get_location:              [:get, 'session/:session_id/location'.freeze],
            set_location:              [:post, 'session/:session_id/location'.freeze],

            ### For IME
            ime_get_available_engines: [:get,  'session/:session_id/ime/available_engines'.freeze],
            ime_get_active_engine:     [:get,  'session/:session_id/ime/active_engine'.freeze],
            ime_is_activated:          [:get,  'session/:session_id/ime/activated'.freeze],
            ime_deactivate:            [:post, 'session/:session_id/ime/deactivate'.freeze],
            ime_activate_engine:       [:post, 'session/:session_id/ime/activate'.freeze],

            ### Logs
            get_available_log_types:   [:get, 'session/:session_id/log/types'.freeze],
            get_log:                   [:post, 'session/:session_id/log'.freeze]
          }
        ).freeze
      end # module W3C
    end # module Commands
  end # module Core
end # module Appium
