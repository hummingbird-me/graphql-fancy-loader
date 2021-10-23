module GraphQL
  class FancyLoader
    class Middleware
      attr_reader :key

      def initialize(key:)
        @key = key
      end

      def call(**args); end
    end
  end
end
