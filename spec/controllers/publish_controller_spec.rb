require 'rails_helper'

DATA_DIR = Rails.root.join('spec', 'data', 'publish_controller')
SOURCE_DIR = DATA_DIR.join('source')
TMP_DIR = DATA_DIR.join('tmp')
RESOURCE_NAME = '1'

def expect_no_difference(data, actual_file, expected_file, diff_file)
  File.write(actual_file, data)
  `diff #{expected_file} #{actual_file} > #{diff_file}`
  expect(File.read(diff_file)).to be_empty
end

RSpec.describe PublishController do
  let(:resource_id) { 1 }
  let(:resource_name) { 'publish_diffs' }
  let(:resource) { create(:resource, id: resource_id, abbr: resource_name) }
  let(:resource_dir) { TMP_DIR.join(resource_name) }
  let(:timestamp1) { 100 }
  let(:timestamp2) { 200 }
  let(:timestamp_between) { 150 }

  before do
    FileUtils.mkdir(resource_dir)
    FileUtils.copy_entry(SOURCE_DIR.join('publish_traits1.tsv'), resource_dir.join("publish_traits_#{timestamp1}.tsv"))
    FileUtils.copy_entry(SOURCE_DIR.join('publish_traits2.tsv'), resource_dir.join("publish_traits_#{timestamp2}.tsv"))
    FileUtils.copy_entry(SOURCE_DIR.join('publish_metadata.tsv'), resource_dir.join('publish_metadata.tsv'))
  end

  describe '#new_traits' do
    let(:expected_file) { DATA_DIR.join('expected', 'new_traits.tsv') }
    let(:actual_file) { TMP_DIR.join('new_traits_actual.tsv') }
    let(:diff_file) { TMP_DIR.join('new_traits.diff') }

    context 'when request is valid' do
      context "when 'since' is between most recent timestamp and previous" do
        it 'gives the expected response' do
          get :new_traits, params: { resource_id: resource_id, since: timestamp_between }, format: :tsv
          expect(response).to have_http_status(:ok)
          expect(response.body).to_not be_empty
          expect_no_difference(response.body, actual_file, expected_file, diff_file)
        end
      end
    end
  end

  describe '#removed_traits' do
  end

  describe '#new_metadata' do
  end

  after do
    FileUtils.remove_dir(resource_dir)
  end
end
