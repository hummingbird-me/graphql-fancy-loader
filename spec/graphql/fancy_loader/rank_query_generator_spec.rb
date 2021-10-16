# frozen_string_literal: true

RSpec.describe GraphQL::FancyLoader::RankQueryGenerator do
  subject { described_class.new(column: column, partition_by: partition_by, table: table) }

  let(:column) { :release_order }
  let(:partition_by) { :franchise_id }
  let(:table) { Installment.arel_table }

  describe '#arel' do
    let(:raw_sql) { 'ROW_NUMBER() OVER (PARTITION BY "installments"."franchise_id" ORDER BY "installments"."release_order" ASC) AS release_order_rank' } # rubocop:disable Layout/LineLength

    it 'should return a window function for a RankedModel column' do
      expect(subject.arel).to be_a(Arel::Nodes::As)
      expect(subject.arel.to_sql).to eq(raw_sql)
    end
  end
end
