require 'rails_helper'

RSpec.describe ResourceHarvester do
  before(:all) do
    @path_to_csv = Rails.root.join("spec", "files", "traits.csv")
  end

  let(:resource) { create(:resource) }
  # NOTE: specifying "file" here only for convenience. It SHOULD be set by the
  # "fetch" routine, but we don't want to rely on that during tests.
  let(:fmt) { create(:format, resource: resource, get_from: @path_to_csv,
    file: @path_to_csv, header_lines: 1, file_type: :csv) }
  let(:harvester) { ResourceHarvester.new(resource) }

  # tid,predicate,value,units,source

  let(:raw_uris) { ["http://domain.com/path/first_pred_term",
    "http://domain.com/path/first_val_term",
    "http://domain.com/path/second_val_term",
    "http://domain.com/path/first_unit_term",
    "http://domain.com/path/second_pred_term"] }
  let(:uris) { raw_uris.each { |u| create(:term, uri: u) } }

  let!(:cols) { [
     create(:field,
       format: fmt,
       position: 1,
       expected_header: "tid",
       map_to_table: :nodes,
       map_to_field: :resource_pk),
     create(:field,
       format: fmt,
       position: 2,
       expected_header: "predicate",
       map_to_table: :vernaculars,
       map_to_field: :verbatim),
     create(:field,
       format: fmt,
       position: 3,
       expected_header: "value",
       map_to_table: :vernaculars,
       map_to_field: :ref_fk),
     create(:field,
       format: fmt,
       position: 4,
       expected_header: "units",
       map_to_table: :vernaculars,
       map_to_field: :language_code_verbatim),
     create(:field,
       format: fmt,
       position: 5,
       expected_header: "source",
       map_to_table: :vernaculars,
       map_to_field: :language_code_verbatim)
    ] }

  describe "#create_harvest_instance" do
    before { harvester.create_harvest_instance }

    it { expect(harvester.start).not_to be_nil }
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
          position: 6,
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

  context "with an expectation of known URIs in first field" do
    describe "#validate" do
      it "logs an exception" do
        harvester.create_harvest_instance
        harvester.harvest.formats.first.fields.first.update_attribute(:validation, Field.validations[:must_know_uris])
        harvester.validate
        expect(harvester.harvest.hlogs.first.line).to eq(2)
        expect(harvester.harvest.hlogs.first.warns?).to be true
        expect(harvester.harvest.hlogs.first.message).to match(/URI/)
      end
    end
  end

  context "with an expectation of non-null source" do
    describe "#validate" do
      it "logs an exception" do
        harvester.create_harvest_instance
        harvester.harvest.formats.first.fields.last.update_attribute(:can_be_empty, false)
        harvester.validate
        expect(harvester.harvest.hlogs.first.line).to eq(3)
        expect(harvester.harvest.hlogs.first.warns?).to be true
        expect(harvester.harvest.hlogs.first.message).to match(/empty/)
      end
    end
  end

  context "with an expectation of integer" do
    describe "#validate" do
      it "logs an exception" do
        harvester.create_harvest_instance
        harvester.harvest.formats.first.fields.last.must_be_integers!
        harvester.validate
        expect(harvester.harvest.hlogs.first.line).to eq(2)
        expect(harvester.harvest.hlogs.first.warns?).to be true
        expect(harvester.harvest.hlogs.first.message).to match(/non-integer/)
      end
    end
  end
end
