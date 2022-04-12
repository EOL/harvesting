require 'rails_helper'

DATA_DIR = Rails.root.join('spec', 'data', 'publish_diff')
SOURCE_DIR = DATA_DIR.join('source')
TRAIT_SOURCE1 = SOURCE_DIR.join('publish_traits1.tsv')
TRAIT_SOURCE2 = SOURCE_DIR.join('publish_traits2.tsv')
META_SOURCE = SOURCE_DIR.join('publish_metadata.tsv')
META_SOURCE_NO_EXTERNAL = SOURCE_DIR.join('publish_metadata_no_external.tsv')
TMP_DIR = DATA_DIR.join('tmp')
EXPECTED_DIR = DATA_DIR.join('expected')
EXPECTED_NEW_TRAITS_DIFF_FILE = EXPECTED_DIR.join('new_traits.csv')
EXPECTED_REMOVED_TRAITS_DIFF_FILE = EXPECTED_DIR.join('removed_traits.csv')
EXPECTED_NEW_METADATA_DIFF_FILE = EXPECTED_DIR.join('new_metadata.csv')
EXPECTED_EXTERNAL_ONLY_META_FILE = EXPECTED_DIR.join('new_metadata_external_only.csv')

RSpec.describe PublishDiff, type: :model do
  let(:timestamp1) { 100 }
  let(:timestamp2) { 200 }
  let(:time_between) { 150 }

  before do
    Resource.data_dir_path = TMP_DIR
    # clear directory here, rather than in after block, because it might be helpful to inspect files on failure
    FileUtils.remove_dir(TMP_DIR) if File.exist?(TMP_DIR)
  end

  describe '.since' do
    context 'when resource.can_perform_trait_diffs is true' do
      let(:resource_id) { 1 }
      let(:resource_name) { 'publish_diffs' }
      let(:resource_dir) { TMP_DIR.join(resource_name) }
      let!(:resource) { create(:resource, id: resource_id, abbr: resource_name, can_perform_trait_diffs: true) }
      let(:publish_meta_path) { resource_dir.join('publish_metadata.tsv') }
      let(:t1_path) { resource_dir.join("publish_traits_#{timestamp1}.tsv") }
      let(:t2_path) { resource_dir.join("publish_traits_#{timestamp2}.tsv") }
      
      before do
        FileUtils.mkdir_p(resource_dir) # Also creates TMP_DIR
        FileUtils.touch(publish_meta_path)
      end

      context 'when all publish files are timestamped' do
        let(:ignore_timestamp1) { 50 }
        let(:ignore_timestamp2) { 170 }

        before do
          FileUtils.touch(t1_path)
          FileUtils.touch(t2_path)

          # these should be ignored by implementation -- just create some extra files to ensure the correct ones are identified
          FileUtils.touch(resource_dir.join("publish_traits_#{ignore_timestamp1}.tsv"))
          FileUtils.touch(resource_dir.join("publish_traits_#{ignore_timestamp2}.tsv"))
        end

        context 'when since time is between file timestamps' do
          subject(:diff) { PublishDiff.since(resource, time_between) }

          context "when there isn't an existing record" do
            it do
              expect(diff.status).to eq('pending')
              expect(diff.t1).to eq(timestamp1)
              expect(diff.t2).to eq(timestamp2)
            end
          end

          context 'when there is an existing record' do
            let!(:record) { create(:publish_diff, t1: timestamp1, t2: timestamp2, resource_id: resource.id) }

            it { expect(diff).to eq(record) }
          end
        end

        context 'when since time is before first file timestamp' do
          let(:time) { 10 }
          subject(:diff) { PublishDiff.since(resource, time) }

          it do
            expect(diff.status).to eq('completed')
            expect(diff.new_traits_path).to eq(t2_path.to_s)
            expect(diff.remove_all_traits?).to eq(true)
            expect(diff.removed_traits_path).to be_nil
            expect(diff.new_metadata_path).to eq(publish_meta_path.to_s)
          end
        end
      end

      context 'when there is a non-timestamped harvested_traits.tsv file present' do
        context 'when it is the only file' do
          let(:trait_path) { resource_dir.join('publish_traits.tsv') }

          before do
            FileUtils.touch(trait_path)
          end

          subject(:diff) { PublishDiff.since(resource, 100) }

          it do 
            expect(diff.status).to eq('completed')
            expect(diff.new_traits_path).to eq(trait_path.to_s)
            expect(diff.remove_all_traits).to eq(true)
            expect(diff.removed_traits_path).to be_nil
            expect(diff.new_metadata_path).to eq(publish_meta_path.to_s)
          end
        end
      end

      context 'when there are also timestamped files' do
        context 'when since is before earliest timestamp' do
          let(:recent_trait_path) { resource_dir.join('publish_traits_100.tsv') }
          subject(:diff) { PublishDiff.since(resource, 25) }

          before do
            FileUtils.touch(resource_dir.join('publish_traits.tsv'))
            FileUtils.touch(recent_trait_path)
            FileUtils.touch(SOURCE_DIR.join('publish_traits_50.tsv'))
          end

          it do 
            expect(diff.status).to eq('completed')
            expect(diff.new_traits_path).to eq(recent_trait_path.to_s)
            expect(diff.remove_all_traits).to eq(true)
            expect(diff.removed_traits_path).to be_nil
            expect(diff.new_metadata_path).to eq(publish_meta_path.to_s)
          end
        end

        context 'when since is between most recent and another timestamp' do
          subject(:diff) { PublishDiff.since(resource, time_between) }

          before do
            FileUtils.touch(resource_dir.join("publish_traits_#{timestamp1}.tsv"))
            FileUtils.touch(resource_dir.join("publish_traits_#{timestamp2}.tsv"))
            FileUtils.touch(SOURCE_DIR.join('publish_traits.tsv'))
          end

          it do
            expect(diff.status).to eq('pending')
            expect(diff.t1).to eq(timestamp1)
            expect(diff.t2).to eq(timestamp2)
          end
        end

        context 'when since is nil' do
          subject(:diff) { PublishDiff.since(resource, nil) }

          before do
            FileUtils.touch(t1_path)
            FileUtils.touch(t2_path)
          end

          it do
            expect(diff.status).to eq('completed')
            expect(diff.new_traits_path).to eq(t2_path.to_s)
            expect(diff.new_metadata_path).to eq(publish_meta_path.to_s)
            expect(diff.removed_traits_path).to be_nil
            expect(diff.remove_all_traits).to eq(true)
          end
        end
      end
    end

    context 'when resource.can_perform_trait_diffs is false' do
      let(:resource_id) { 2 }
      let(:resource_name) { 'no_diffs' }
      let!(:resource) { create(:resource, id: resource_id, abbr: resource_name, can_perform_trait_diffs: false) }
      let(:resource_dir) { TMP_DIR.join(resource_name) }
      let(:recent_traits_path) { resource_dir.join("publish_traits_#{timestamp2}.tsv") }
      subject(:diff) { PublishDiff.since(resource, time_between) }

      before do
        FileUtils.mkdir_p(resource_dir)
        FileUtils.touch(resource_dir.join("publish_traits_#{timestamp1}.tsv"))
        FileUtils.touch(recent_traits_path)
      end

      it do
        expect(diff.status).to eq('completed')
        expect(diff.new_traits_path).to eq(recent_traits_path.to_s)
        expect(diff.remove_all_traits?).to eq(true)
        expect(diff.removed_traits_path).to be_nil
        expect(diff.new_metadata_path).to eq(resource_dir.join('publish_metadata.tsv').to_s)
      end
    end
  end

  describe '#perform' do
    let(:resource_id) { 1 }
    let(:resource_name) { 'publish_diffs' }
    let(:resource_dir) { TMP_DIR.join(resource_name) }
    let!(:resource) { create(:resource, id: resource_id, abbr: resource_name, can_perform_trait_diffs: true) }
    let(:publish_meta_path) { resource_dir.join('publish_metadata.tsv') }

    subject(:diff) { PublishDiff.since(resource, time_between) }

    before { FileUtils.mkdir_p(resource_dir) } # Also creates TMP_DIR 

    context 'when the trait files differ' do
      before do
        FileUtils.copy_entry(TRAIT_SOURCE1, resource_dir.join("publish_traits_#{timestamp1}.tsv"))
        FileUtils.copy_entry(TRAIT_SOURCE2, resource_dir.join("publish_traits_#{timestamp2}.tsv"))
      end

      context 'when there is a publish_metadata.tsv file' do
        before do
          FileUtils.copy_entry(META_SOURCE, resource_dir.join('publish_metadata.tsv'))
        end

        it 'creates the expected diff files and sets the expected attributes' do
          diff.perform_without_delay
          diff.reload # ensure that what we're getting is persisted
        
          expect(diff.status).to eq('completed')
          expect(diff.new_traits_path).to_not be_nil
          expect(diff.removed_traits_path).to_not be_nil
          expect(diff.new_metadata_path).to_not be_nil
          expect(diff.remove_all_traits?).to eq(false)
          expect(File.read(diff.new_traits_path)).to eq(File.read(EXPECTED_NEW_TRAITS_DIFF_FILE)) 
          expect(File.read(diff.removed_traits_path)).to eq(File.read(EXPECTED_REMOVED_TRAITS_DIFF_FILE)) 
          expect(File.read(diff.new_metadata_path)).to eq(File.read(EXPECTED_NEW_METADATA_DIFF_FILE)) 
        end
      end

      context "when there isn't a publish_metadata.tsv file" do
        it 'creates the expected diff files and sets the expected attributes, with nil new_metadata_path' do
          diff.perform_without_delay
          diff.reload # ensure that what we're getting is persisted
        
          expect(diff.status).to eq('completed')
          expect(diff.new_traits_path).to_not be_nil
          expect(diff.removed_traits_path).to_not be_nil
          expect(diff.new_metadata_path).to be_nil
          expect(diff.remove_all_traits?).to eq(false)
          expect(File.read(diff.new_traits_path)).to eq(File.read(EXPECTED_NEW_TRAITS_DIFF_FILE)) 
          expect(File.read(diff.removed_traits_path)).to eq(File.read(EXPECTED_REMOVED_TRAITS_DIFF_FILE)) 
        end
      end

      context "when the trait files don't differ" do
        before do
          FileUtils.copy_entry(TRAIT_SOURCE1, resource_dir.join("publish_traits_#{timestamp1}.tsv"))
          FileUtils.copy_entry(TRAIT_SOURCE1, resource_dir.join("publish_traits_#{timestamp2}.tsv"))
        end

        context 'when there is no external metadata' do
          before { FileUtils.copy_entry(META_SOURCE_NO_EXTERNAL, resource_dir.join('publish_metadata.tsv')) }

          it 'sets all path attributes to nil' do
            diff.perform_without_delay
            diff.reload # ensure that what we're getting is persisted

            expect(diff.status).to eq('completed')
            expect(diff.new_traits_path).to be_nil
            expect(diff.removed_traits_path).to be_nil
            expect(diff.new_metadata_path).to be_nil
            expect(diff.remove_all_traits?).to eq(false)
          end
        end

        context 'when there is external metadata' do
          before { FileUtils.copy_entry(META_SOURCE, resource_dir.join('publish_metadata.tsv')) }

          it 'adds them to the new metadata file and sets trait paths to nil' do
            diff.perform_without_delay
            diff.reload # ensure that what we're getting is persisted

            expect(diff.status).to eq('completed')
            expect(diff.new_traits_path).to be_nil
            expect(diff.removed_traits_path).to be_nil
            expect(diff.new_metadata_path).to_not be_nil
            expect(diff.remove_all_traits?).to eq(false)
            expect(File.read(diff.new_metadata_path)).to eq(File.read(EXPECTED_EXTERNAL_ONLY_META_FILE))
          end
        end
      end
    end
  end
  
  after do
    Resource.data_dir_path = nil
  end
end
