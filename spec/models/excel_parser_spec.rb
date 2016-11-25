require 'rails_helper'

RSpec.describe ExcelParser do
  before(:all) do
    # This takes a long time (about 1.5 sec on my machine), so you only want to
    # do it once:
    file = Rails.root.join("spec", "files", "t.xlsx")
    @parser = ExcelParser.new(file, header_lines: 2, sheet: 3)
  end

  context "with files/basic_meta.xml (q.v.)" do
    let(:cols) { [
       "TaxonID http://rs.tdwg.org/dwc/terms/taxonID",
       "Name http://rs.tdwg.org/dwc/terms/vernacularName",
       "Source Reference http://purl.org/dc/terms/source",
       "Language http://purl.org/dc/terms/language",
       "Locality http://rs.tdwg.org/dwc/terms/locality",
       "CountryCode http://rs.tdwg.org/dwc/terms/countryCode",
       "IsPreferredName http://rs.gbif.org/terms/1.0/isPreferredName",
       "TaxonRemarks http://rs.tdwg.org/dwc/terms/taxonRemarks"
    ] }

    describe "#rows_as_hashes has expected values" do
      let(:row) {
        i = 0
        row = nil
        @parser.rows_as_hashes do |r|
          row = r
          break if i > 5
          i += 1
        end
        row
      }

      it { expect(row[cols[0]]).to eq("taxon9876") }
      it { expect(row[cols[1]]).to eq("Great Blue Heron") }
      it { expect(row[cols[2]]).to be_nil }
      it { expect(row[cols[3]]).to eq("en") }
      # Etc... I think that's enough to prove the point.
    end
  end
end
