module GraphQL
  class FancyLoader::Middleware::PunditMiddleware < GraphQL::FancyLoader::Middleware
    def post_initialize(model:)
      @model = model
      @key = GraphQL::FancyLoader.pundit_key
    end

    def call
      scope.new(user, query).resolve
    end

    private

    # A pundit scope class to apply to our querying
    def scope
      @scope ||= ::Pundit::PolicyFinder.new(@model).scope!
    end

    def user
      @user ||= context[@key]
    end
  end
end
