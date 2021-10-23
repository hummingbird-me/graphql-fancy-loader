module GraphQL
  class FancyLoader::Middleware::PunditMiddleware < GraphQL::FancyLoader::Middleware
    def call(model:, query:, context:)
      scope = ::Pundit::PolicyFinder.new(model).scope!
      user = context[key]
      scope.new(user, query).resolve
    end
  end
end
