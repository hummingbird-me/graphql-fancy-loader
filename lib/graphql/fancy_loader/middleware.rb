module GraphQL
  class FancyLoader
    class Middleware
      attr_reader :query, :context

      def initialize(query:, context:, **args)
        @query = query
        @context = context

        post_initialize(**args)
      end

      def post_initialize(**_); end

      def call; end
    end
  end
end
