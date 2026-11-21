require 'active_support/concern'
require 'active_support/ordered_options'

module GraphQL
  class FancyLoader < GraphQL::Batch::Loader
    # Provides the +config+, +configure+ and +middleware+ methods on FancyLoader. This is a stand-in
    # for +ActiveSupport::Configurable+, which is deprecated in Rails 8.1 and will be removed in
    # Rails 8.2.
    module Configurable
      extend ActiveSupport::Concern

      class_methods do
        # The configuration for this loader. Subclasses inherit the configuration of their parent,
        # and can override it without changing the parent.
        #
        # @return [ActiveSupport::InheritableOptions]
        def config
          @config ||= if superclass.respond_to?(:config)
                        superclass.config.inheritable_copy
                      else
                        ActiveSupport::InheritableOptions.new
                      end
        end

        # @yieldparam config [ActiveSupport::InheritableOptions]
        def configure
          yield config
        end

        def middleware
          config.middleware
        end

        def middleware=(value)
          config.middleware = value
        end
      end

      # The configuration for this instance, inherited from its class.
      #
      # @return [ActiveSupport::InheritableOptions]
      def config
        @config ||= self.class.config.inheritable_copy
      end

      def middleware
        config.middleware
      end

      def middleware=(value)
        config.middleware = value
      end
    end
  end
end
