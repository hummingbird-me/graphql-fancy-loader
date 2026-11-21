RSpec.describe GraphQL::FancyLoader do
  it 'has a version number' do
    expect(GraphQL::FancyLoader::VERSION).not_to be_nil
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
