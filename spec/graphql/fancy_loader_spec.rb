RSpec.describe GraphQL::FancyLoader do
  it 'has a version number' do
    expect(GraphQL::FancyLoader::VERSION).not_to be_nil
  end

  describe '.connection_for' do
    let(:schema) do
      loader = Class.new(described_class) do
        from Post
        sort :id
      end

      post_type = Class.new(GraphQL::Schema::Object) do
        graphql_name 'Post'
        field :id, GraphQL::Types::ID, null: false
      end

      user_type = Class.new(GraphQL::Schema::Object) do
        graphql_name 'User'
        field :posts, post_type.connection_type, null: false do
          argument :sort, loader.sort_argument, required: false
        end

        define_method(:posts) do |sort: [{ on: :id, direction: :asc }]|
          loader.connection_for({ find_by: :user_id, sort: sort }, object.id)
        end
      end

      query_type = Class.new(GraphQL::Schema::Object) do
        graphql_name 'Query'
        field :users, [user_type], null: false do
          argument :ids, [GraphQL::Types::ID], required: true
        end

        def users(ids:)
          User.where(id: ids).order(:id)
        end
      end

      Class.new(GraphQL::Schema) do
        query query_type
        use GraphQL::Batch
      end
    end

    let(:users) { create_list(:user, 2) }
    let!(:posts) { users.map { |user| create_list(:post, 4, user: user).sort_by(&:id) } }

    def execute(posts_args)
      result = schema.execute(<<~GRAPHQL, variables: { ids: users.map(&:id) })
        query($ids: [ID!]!) {
          users(ids: $ids) {
            posts(#{posts_args}) {
              nodes { id }
              pageInfo { hasNextPage hasPreviousPage endCursor }
            }
          }
        }
      GRAPHQL

      expect(result['errors']).to be_nil
      result['data']['users'].map { |user| user['posts'] }
    end

    def ids_in(connections)
      connections.map { |connection| connection['nodes'].map { |node| node['id'].to_i } }
    end

    it 'should load the connections for every key in a single query' do
      queries = []
      counter = ->(*, payload) { queries << payload[:sql] if payload[:sql].include?('ROW_NUMBER()') }

      connections = ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') do
        execute('first: 2, sort: [{ on: ID, direction: DESCENDING }]')
      end

      expect(ids_in(connections)).to eq(posts.map { |list| list.reverse.first(2).map(&:id) })
      expect(queries.count).to eq(1)
    end

    it 'should paginate using the cursors it returns' do
      first_page = execute('first: 3')
      expect(ids_in(first_page)).to eq(posts.map { |list| list.first(3).map(&:id) })
      expect(first_page.map { |connection| connection['pageInfo'] }).to all(
        include('hasNextPage' => true, 'hasPreviousPage' => false)
      )

      cursor = first_page.first['pageInfo']['endCursor']
      second_page = execute(%(first: 3, after: "#{cursor}"))
      expect(ids_in(second_page)).to eq(posts.map { |list| list.last(1).map(&:id) })
      expect(second_page.map { |connection| connection['pageInfo'] }).to all(
        include('hasNextPage' => false, 'hasPreviousPage' => true)
      )
    end
  end

  describe 'configuration' do
    let(:middleware) { [->(query:, **) { query }] }

    around do |example|
      original = described_class.middleware
      example.run
    ensure
      described_class.middleware = original
    end

    describe '.configure' do
      it 'should yield the config' do
        expect { |b| described_class.configure(&b) }.to yield_with_args(described_class.config)
      end

      it 'should update the middleware on the class' do
        list = middleware
        described_class.configure { |config| config.middleware = list }

        expect(described_class.middleware).to eq(middleware)
        expect(described_class.config.middleware).to eq(middleware)
        expect(described_class.config[:middleware]).to eq(middleware)
      end
    end

    describe '.middleware' do
      it 'should default to nil' do
        expect(described_class.middleware).to be_nil
      end

      it 'should be assignable without a configure block' do
        described_class.middleware = middleware

        expect(described_class.config.middleware).to eq(middleware)
      end

      it 'should be inherited by subclasses' do
        subclass = Class.new(described_class)
        described_class.middleware = middleware

        expect(subclass.middleware).to eq(middleware)
      end

      it 'should be overridable in a subclass without changing the parent' do
        subclass = Class.new(described_class)
        subclass.middleware = middleware

        expect(subclass.middleware).to eq(middleware)
        expect(described_class.middleware).to be_nil
      end

      it 'should be readable from a loader instance' do
        described_class.middleware = middleware
        loader = described_class.new(find_by: :user_id, sort: [])

        expect(loader.middleware).to eq(middleware)
        expect(loader.config.middleware).to eq(middleware)
      end

      it 'should be overridable on a loader instance without changing the class' do
        loader = described_class.new(find_by: :user_id, sort: [])
        loader.middleware = middleware

        expect(loader.middleware).to eq(middleware)
        expect(described_class.middleware).to be_nil
      end
    end
  end
end
