require 'rails_helper'

RSpec.describe CsvParser do
  before(:all) do
    # This takes a long time (about 1.5 sec on my machine), so you only want to
    # do it once:
    file = Rails.root.join("spec", "files", "traits.csv")
    @parser = CsvParser.new(file)
  end

  context "with files/basic_meta.xml (q.v.)" do
    let(:cols) { %w[tid predicate value units source] }

    describe "#rows_as_hashes has expected values" do
      let(:row) {
        row = nil
        @parser.rows_as_hashes do |r|
          row = r
          break
        end
        row
      }

      it { expect(row[cols[0]]).to eq("3") }
      it { expect(row[cols[1]]).to eq("http://domain.com/path/second_pred_term") }
      it { expect(row[cols[2]]).to eq("Raw value") }
      it { expect(row[cols[3]]).to be_nil }
      it { expect(row[cols[4]]).to eq("Another source") }
    end
  end
end
