require 'rails_helper'

RSpec.describe ResourceHarvester do
  before(:all) do
    @path_to_csv = Rails.root.join("spec", "files", "traits.csv")
  end

  let(:resource) { create(:resource) }
  # NOTE: specifying "file" here only for convenience. It SHOULD be set by the
  # "fetch" routine, but we don't want to rely on that during tests.
  let(:fmt) { create(:format, resource: resource, get_from: @path_to_excel,
    file: @path_to_excel, header_lines: 1, file_type: :csv) }
  let(:harvester) { ResourceHarvester.new(resource) }

  let!(:cols) { [
     create(:field,
       format: fmt,
       position: 1,
       expected_header: "TaxonID http://rs.tdwg.org/dwc/terms/taxonID",
       map_to_table: :nodes,
       map_to_field: :resource_pk),
     create(:field,
       format: fmt,
       position: 2,
       expected_header: "Name http://rs.tdwg.org/dwc/terms/vernacularName",
       map_to_table: :vernaculars,
       map_to_field: :verbatim),
     create(:field,
       format: fmt,
       position: 3,
       expected_header: "Source Reference http://purl.org/dc/terms/source",
       map_to_table: :vernaculars,
       map_to_field: :source_reference),
     create(:field,
       format: fmt,
       position: 4,
       expected_header: "Language http://purl.org/dc/terms/language",
       map_to_table: :vernaculars,
       map_to_field: :language_code_verbatim),
     create(:field,
       format: fmt,
       position: 5,
       expected_header: "Locality http://rs.tdwg.org/dwc/terms/locality",
       map_to_table: :vernaculars,
       map_to_field: :language_code_verbatim),
     create(:field,
       format: fmt,
       position: 6,
       expected_header: "CountryCode http://rs.tdwg.org/dwc/terms/countryCode",
       map_to_table: :vernaculars,
       map_to_field: :language_code_verbatim),
     create(:field,
       format: fmt,
       position: 7,
       expected_header: "IsPreferredName http://rs.gbif.org/terms/1.0/isPreferredName",
       map_to_table: :vernaculars,
       map_to_field: :is_preferred),
     create(:field,
       format: fmt,
       position: 8,
       expected_header: "TaxonRemarks http://rs.tdwg.org/dwc/terms/taxonRemarks",
       map_to_table: :vernaculars,
       map_to_field: :remarks)
    ] }

  describe "#create_harvest_instance" do
    before { harvester.create_harvest_instance }

    it { expect(harvester.harvest).not_to be_nil }
  end

  context "with a valid format" do
    describe "#validate" do
      it "validates test file" do
        harvester.create_harvest_instance
        expect { harvester.validate }.not_to raise_error
      end
    end
  end

  context "with a missing column in the file" do
    describe "#validate" do
      let!(:extra_field) do
        create(:field,
          format: fmt,
          position: 9,
          expected_header: "Missing",
          map_to_table: :vernaculars,
          map_to_field: :language_group_code)
      end

      it "raises an exception" do
        harvester.create_harvest_instance
        expect { harvester.validate }.to raise_error(Exceptions::ColumnMissing)
      end
    end
  end

  context "with an extra column in the file" do
    describe "#validate" do
      it "raises an exception" do
        Field.last.destroy
        harvester.create_harvest_instance
        expect { harvester.validate }.to raise_error(Exceptions::ColumnUnmatched)
      end
    end
  end

  context "with an incorrect column in the file" do
    describe "#validate" do
      it "raises an exception" do
        Field.last.update_attribute(:expected_header, "nothing good")
        harvester.create_harvest_instance
        expect { harvester.validate }.to raise_error(Exceptions::ColumnMismatch)
      end
    end
  end
end
