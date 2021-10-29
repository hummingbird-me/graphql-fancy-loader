# GraphQL::FancyLoader

FancyLoader is used to help optimize your GraphQL queries by utilizing lazy loading in addition to allowing orders, limits, and pagination. Behind the scenes we are utilizing `GraphQL::Batch::Loader` from the [graphql-batch gem](https://github.com/Shopify/graphql-batch).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-fancy_loader'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install graphql-fancy_loader

## Basic Usage

For all these examples, this is the basic structure.

```
# User
# id, email, created_at, updated_at

has_many :posts
```

```
# Post
# id, user_id, title, created_at, updated_at

belongs_to :user
```

```
# Post Likes (join table)
# id, user_id, post_id, created_at, updated_at

belongs_to :user
belongs_to :post
```

```
# graphql/loaders/posts_loader
class Loaders::PostsLoader < GraphQL::FancyLoader
  from Post
  sort :created_at
end
```

Now that you have created your loader, it is time to implement it with your graphql type(s).

```
# graphql/types/user.rb

class Types::User < Types::BaseObject
  field :posts, Types::Post.connection_type, null: false do
    description 'All posts this user has made.'
    argument :sort, Loaders::PostsLoader.sort_argument, required: false  # This argument type is auto-created
  end

  def posts(sort: [{ on: :created_at, direction: :desc }])
    Loaders::PostsLoader.connection_for({
      find_by: :user_id,
      sort: sort
    }, object.id)
  end
end
```

This is how you would test your loader returns what is expected.

```
RSpec.describe Loaders::PostsLoader do
  let!(:user) { create(:user) }
  let!(:posts) { create_list(:post, 10, user: user) }
  let(:context) { GraphQL::Query::Context.new(query: OpenStruct.new(schema: <your-schema-name>), values: nil, object: nil) }
  let(:sort) { [{ on: :created_at, direction: :desc }] }

  it 'loads all the posts for a user' do
    posts = GraphQL::Batch.batch do
      described_class.connection_for({
        find_by: :user_id,
        sort: sort,
        context: context
      }, user.id).nodes
    end

    expect(posts.count).to eq(user.posts.count)
  end
end
```

## Advanced Examples

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hummingbird-me/graphql-fancy-loader.

## License

The gem is available as open source under the terms of the [Apache-2.0 License](https://opensource.org/licenses/Apache-2.0).
