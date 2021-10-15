# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql/fancy_loader/version'

Gem::Specification.new do |spec|
  spec.name          = 'graphql-fancy_loader'
  spec.version       = GraphQL::FancyLoader::VERSION
  spec.authors       = %w[Toyhammered NuckChorris]
  spec.email         = ['help@kitsu.io']

  spec.summary       = ''
  spec.description   = ''
  spec.homepage      = ''
  spec.license       = 'Apache-2.0'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'graphql', '>= 1.3', '< 2'
  spec.add_runtime_dependency 'graphql-batch', '>= 0.4.3', '< 1'

  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
