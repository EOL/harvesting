RSpec.describe MetaParser do
  describe "#parse" do
    # NOTE: we really are reading from an actual file, here. I want to prove
    # that works and that nokogiri is doing what we expect; I don't want to mock
    # all of those internals.
    context "with files/basic_meta.xml (q.v.)" do
      let(:meta_file) { Rails.root.join("spec", "files", "basic_meta.xml") }
      let(:resource) { double(Resource, id: 123, harvest_from: meta_file) }

      subject(:parser) { MetaParser.new(resource) }

      before(:each) do
        allow(Table).to receive(:create) { double(Table) }
        allow(FileLoc).to receive(:create) { double(FileLoc) }
        allow(Field).to receive(:create) { double(Field) }
      end

      it "creates a table with the right params" do
        subject
        expect(Table).to have_received(:create).at_least(1).times.with(
          resource_id: 123,
          header_lines: 2,
          field_sep: ",",
          line_sep: "\r\n",
          utf8: true
        )
      end
    end
  end
end
