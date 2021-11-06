module GraphQL
  # HACK: This allows us to import the version number in the gemspec
  class FancyLoader < (begin
    require 'graphql/batch'
    GraphQL::Batch::Loader
  rescue LoadError
    BasicObject
  end)
    VERSION = '0.1.2'.freeze
  end
end
