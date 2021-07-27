require 'rails_helper'

DATA_DIR = Rails.root.join('spec', 'data', 'publish_controller')
SOURCE_DIR = DATA_DIR.join('source')
TRAIT_SOURCE1 = SOURCE_DIR.join('publish_traits1.tsv')
TRAIT_SOURCE2 = SOURCE_DIR.join('publish_traits2.tsv')
META_SOURCE = SOURCE_DIR.join('publish_metadata.tsv')
TMP_DIR = DATA_DIR.join('tmp')
EXPECTED_DIR = DATA_DIR.join('expected')
EXPECTED_NEW_TRAITS_DIFF_FILE = EXPECTED_DIR.join('new_traits.tsv') # TODO: should be csv
EXPECTED_REMOVE_ALL_TRAITS_FILE = EXPECTED_DIR.join('remove_all_traits.csv')
EXPECTED_REMOVED_TRAITS_DIFF_FILE = EXPECTED_DIR.join('removed_traits.tsv')
EXPECTED_NEW_METADATA_DIFF_FILE = EXPECTED_DIR.join('new_metadata.tsv')
EXPECTED_EMPTY_NEW_TRAITS_FILE = EXPECTED_DIR.join('new_traits_empty.csv')
EXPECTED_EMPTY_REMOVED_TRAITS_FILE = EXPECTED_DIR.join('removed_traits_empty.csv')
EXPECTED_EMPTY_NEW_METADATA_FILE = EXPECTED_DIR.join('new_metadata_empty.csv')

# temp files created to examine diffs
RESPONSE_FILE = TMP_DIR.join('response.csv')
DIFF_FILE = TMP_DIR.join('expected_response.diff')

RSpec.describe PublishController do
  let(:resource_id) { 1 }
  let(:resource_name) { 'publish_diffs' }
  let(:resource_dir) { TMP_DIR.join(resource_name) }
  let!(:resource) { create(:resource, id: resource_id, abbr: resource_name, can_perform_trait_diffs: true) }
  let(:resource_no_diffs_id) { 2 }
  let(:resource_no_diffs_name) { 'np_resource' }
  let!(:resource_no_diffs) { create(:resource, id: resource_no_diffs_id, abbr: resource_no_diffs_name, can_perform_trait_diffs: false) }
  let(:resource_no_diffs_dir) { TMP_DIR.join(resource_no_diffs_name) }

  #before do
  #  Resource.data_dir_path = TMP_DIR
  #  # clear directory here, rather than in after block, because it might be helpful to inspect files on failure
  #  FileUtils.remove_dir(TMP_DIR) if File.exist?(TMP_DIR)
  #  FileUtils.mkdir_p(resource_dir) # Also creates TMP_DIR
  #end

  #def expect_no_difference(data, expected_file)
  #  File.write(RESPONSE_FILE, data)
  #  `diff #{expected_file} #{RESPONSE_FILE} > #{DIFF_FILE}`
  #  # diff uses 2 for errors, 1 for "there's a difference". The next line catches
  #  # the 1 case and outputs a more helpful error than this would (the diff string).
  #  expect($?.exitstatus).to be < 2 
  #  expect(File.read(DIFF_FILE)).to be_empty
  #end

  #def make_request(action, req_params)
  #  get action, params: req_params, format: :csv
  #end

  #def validate_response(expected_file)
  #  expect(response).to have_http_status(:ok)
  #  expect(response.body).to_not be_empty
  #  expect_no_difference(response.body, expected_file)
  #end

  #def expect_response(action, req_params, expected_file)
  #  make_request(action, req_params)
  #  validate_response(expected_file)
  #end

  #describe '#new_traits' do
  #  def make_new_traits_request(req_params)
  #    make_request(:new_traits, req_params)
  #  end

  #  def expect_new_traits_response(req_params, expected_file)
  #    expect_response(:new_traits, req_params, expected_file)
  #  end

  #  context 'when request is valid' do
  #    let(:timestamp1) { 100 }
  #    let(:timestamp2) { 200 }

  #    context 'when there is no trait file in the resource directory' do
  #      it do
  #        make_new_traits_request(resource_id: resource_id, since: 100)
  #        expect(response).to have_http_status(:no_content)
  #      end
  #    end

  #    context 'when there are no new traits' do
  #      before do
  #        FileUtils.copy_entry(TRAIT_SOURCE1, resource_dir.join("publish_traits_#{timestamp1}.tsv"))
  #        FileUtils.copy_entry(TRAIT_SOURCE1, resource_dir.join("publish_traits_#{timestamp2}.tsv"))
  #      end

  #      it { expect_new_traits_response({ resource_id: resource_id, since: 150 }, EXPECTED_EMPTY_NEW_TRAITS_FILE) }
  #    end

  #    context 'when resource.has_persistent_trait_pks is false' do
  #      before do
  #        FileUtils.mkdir(resource_no_diffs_dir)
  #        FileUtils.copy_entry(TRAIT_SOURCE1, resource_no_diffs_dir.join("publish_traits_#{timestamp1}.tsv"))
  #        FileUtils.copy_entry(TRAIT_SOURCE2, resource_no_diffs_dir.join("publish_traits_#{timestamp2}.tsv"))
  #      end

  #      it { expect_new_traits_response({ resource_id: resource_no_diffs_id, since: 150 }, TRAIT_SOURCE2) }

  #      after do
  #        FileUtils.remove_dir(resource_no_diffs_dir)
  #      end
  #    end

  #    context 'when there are new traits' do
  #      context 'when all files are timestamped' do
  #        let(:ignore_timestamp1) { 50 }
  #        let(:ignore_timestamp2) { 170 }

  #        before do
  #          FileUtils.copy_entry(TRAIT_SOURCE1, resource_dir.join("publish_traits_#{timestamp1}.tsv"))
  #          FileUtils.copy_entry(TRAIT_SOURCE2, resource_dir.join("publish_traits_#{timestamp2}.tsv"))

  #          # these should be ignored by implementation -- just create some extra files to ensure the correct ones are used
  #          FileUtils.touch(resource_dir.join("publish_traits_#{ignore_timestamp1}.tsv"))
  #          FileUtils.touch(resource_dir.join("publish_traits_#{ignore_timestamp2}.tsv"))
  #        end

  #        context "when 'since' is absent" do
  #          it { expect_new_traits_response({ resource_id: resource_id }, TRAIT_SOURCE2) }
  #        end

  #        context "when 'since' is between most recent timestamp and a previous one" do
  #          it { expect_new_traits_response({ resource_id: resource_id, since: 150 }, EXPECTED_NEW_TRAITS_DIFF_FILE) }
  #        end

  #        context "when 'since' is before earliest timestamp" do
  #          it { expect_new_traits_response({ resource_id: resource_id, since: 10 }, TRAIT_SOURCE2) }
  #        end

  #        context "when 'since' is after most recent timestamp" do
  #          it do
  #            make_new_traits_request({ resource_id: resource_id, since: 300 })
  #            expect(response).to have_http_status(:no_content)
  #          end
  #        end
  #      end

  #      context 'when there is a non-timestamped published_traits.tsv file present' do
  #        context 'when it is the only file' do
  #          before do
  #            FileUtils.copy_entry(TRAIT_SOURCE2, resource_dir.join('publish_traits.tsv'))
  #          end

  #          it { expect_new_traits_response({ resource_id: resource_id, since: 100 }, TRAIT_SOURCE2) }
  #        end

  #        context 'when there are also timestamped files' do
  #          context 'when since is before earliest timestamp' do
  #            before do
  #              FileUtils.copy_entry(SOURCE_DIR.join('publish_traits1.tsv'), resource_dir.join('publish_traits.tsv'))
  #              FileUtils.copy_entry(SOURCE_DIR.join('publish_traits2.tsv'), resource_dir.join('publish_traits_100.tsv'))
  #              FileUtils.touch(SOURCE_DIR.join('publish_traits_50.tsv'))
  #            end

  #            it { expect_new_traits_response({ resource_id: resource_id, since: 25 }, TRAIT_SOURCE2) }
  #          end

  #          context 'when since is between most recent and another timestamp' do
  #            before do
  #              FileUtils.copy_entry(SOURCE_DIR.join('publish_traits1.tsv'), resource_dir.join('publish_traits_50.tsv'))
  #              FileUtils.copy_entry(SOURCE_DIR.join('publish_traits2.tsv'), resource_dir.join('publish_traits_100.tsv'))
  #              FileUtils.touch(SOURCE_DIR.join('publish_traits.tsv'))
  #            end

  #            it { expect_new_traits_response({ resource_id: resource_id, since: 75 }, EXPECTED_NEW_TRAITS_DIFF_FILE) }
  #          end
  #        end
  #      end
  #    end
  #  end

  #  context 'when request is invalid' do
  #    context 'when resource_id is invalid' do
  #      it { expect { make_new_traits_request(resource_id: 100, since: 100) }.to raise_error(ActiveRecord::RecordNotFound) }
  #    end

  #    context 'when resource_id is missing' do
  #      it { expect { make_new_traits_request(since: 100) }.to raise_error(ActionController::UrlGenerationError) }
  #    end
  #  end
  #end

  #describe '#removed_traits' do
  #  def make_removed_traits_request(req_params)
  #    get :removed_traits, params: req_params, format: :csv
  #  end

  #  def expect_removed_traits_response(req_params, expected_file)
  #    expect_response(:removed_traits, req_params, expected_file)
  #  end

  #  context 'when request is valid' do
  #    let(:timestamp1) { 100 }
  #    let(:timestamp2) { 200 }

  #    context 'when there is no trait file in the resource directory' do
  #      it do
  #        make_removed_traits_request(resource_id: resource_id, since: 100)
  #        expect(response).to have_http_status(:no_content)
  #      end
  #    end

  #    context 'when there are no removed traits' do
  #      before do
  #        FileUtils.copy_entry(TRAIT_SOURCE1, resource_dir.join("publish_traits_#{timestamp1}.tsv"))
  #        FileUtils.copy_entry(TRAIT_SOURCE1, resource_dir.join("publish_traits_#{timestamp2}.tsv"))
  #      end

  #      it do
  #        expect_removed_traits_response({ resource_id: resource_id, since: 150 }, EXPECTED_EMPTY_REMOVED_TRAITS_FILE)
  #      end
  #    end

  #    context 'when resource.has_persistent_trait_pks is false' do
  #      before do
  #        FileUtils.mkdir(resource_no_diffs_dir)
  #        FileUtils.copy_entry(TRAIT_SOURCE1, resource_no_diffs_dir.join("publish_traits_#{timestamp1}.tsv"))
  #        FileUtils.copy_entry(TRAIT_SOURCE2, resource_no_diffs_dir.join("publish_traits_#{timestamp2}.tsv"))
  #      end

  #      it { expect_removed_traits_response({ resource_id: resource_no_diffs_id, since: 150 }, EXPECTED_REMOVE_ALL_TRAITS_FILE) }

  #      after do
  #        FileUtils.remove_dir(resource_no_diffs_dir)
  #      end
  #    end

  #    context 'when there are removed traits' do
  #      context 'when all files are timestamped' do
  #        let(:ignore_timestamp1) { 50 }
  #        let(:ignore_timestamp2) { 170 }

  #        before do
  #          FileUtils.copy_entry(TRAIT_SOURCE1, resource_dir.join("publish_traits_#{timestamp1}.tsv"))
  #          FileUtils.copy_entry(TRAIT_SOURCE2, resource_dir.join("publish_traits_#{timestamp2}.tsv"))

  #          # these should be ignored by implementation -- just create some extra files to ensure the correct ones are used
  #          FileUtils.touch(resource_dir.join("publish_traits_#{ignore_timestamp1}.tsv"))
  #          FileUtils.touch(resource_dir.join("publish_traits_#{ignore_timestamp2}.tsv"))
  #        end

  #        context "when 'since' is absent" do
  #          it { expect_removed_traits_response({ resource_id: resource_id }, EXPECTED_REMOVE_ALL_TRAITS_FILE) }
  #        end

  #        context "when 'since' is between most recent timestamp and a previous one" do
  #          it { expect_removed_traits_response({ resource_id: resource_id, since: 150 }, EXPECTED_REMOVED_TRAITS_DIFF_FILE) }
  #        end

  #        context "when 'since' is before earliest timestamp" do
  #          it { expect_removed_traits_response({ resource_id: resource_id, since: 10 }, EXPECTED_REMOVE_ALL_TRAITS_FILE) }
  #        end

  #        context "when 'since' is after most recent timestamp" do
  #          it do
  #            make_removed_traits_request({ resource_id: resource_id, since: 300 })
  #            expect(response).to have_http_status(:no_content)
  #          end
  #        end
  #      end

  #      context 'when there is a non-timestamped published_traits.tsv file present' do
  #        context 'when it is the only file' do
  #          before do
  #            FileUtils.copy_entry(TRAIT_SOURCE2, resource_dir.join('publish_traits.tsv'))
  #          end

  #          it { expect_removed_traits_response({ resource_id: resource_id, since: 100 }, EXPECTED_REMOVE_ALL_TRAITS_FILE) }
  #        end

  #        context 'when there are also timestamped files' do
  #          context 'when since is before earliest timestamp' do
  #            before do
  #              FileUtils.copy_entry(SOURCE_DIR.join('publish_traits1.tsv'), resource_dir.join('publish_traits.tsv'))
  #              FileUtils.copy_entry(SOURCE_DIR.join('publish_traits2.tsv'), resource_dir.join('publish_traits_100.tsv'))
  #              FileUtils.touch(SOURCE_DIR.join('publish_traits_50.tsv'))
  #            end

  #            it { expect_removed_traits_response({ resource_id: resource_id, since: 25 }, EXPECTED_REMOVE_ALL_TRAITS_FILE) }
  #          end

  #          context 'when since is between most recent and another timestamp' do
  #            before do
  #              FileUtils.copy_entry(SOURCE_DIR.join('publish_traits1.tsv'), resource_dir.join('publish_traits_50.tsv'))
  #              FileUtils.copy_entry(SOURCE_DIR.join('publish_traits2.tsv'), resource_dir.join('publish_traits_100.tsv'))
  #              FileUtils.touch(SOURCE_DIR.join('publish_traits.tsv'))
  #            end

  #            it { expect_removed_traits_response({ resource_id: resource_id, since: 75 }, EXPECTED_REMOVED_TRAITS_DIFF_FILE) }
  #          end
  #        end
  #      end
  #    end
  #  end

  #  # TODO: DRY
  #  context 'when request is invalid' do
  #    context 'when resource_id is invalid' do
  #      it { expect { make_removed_traits_request(resource_id: 100, since: 100) }.to raise_error(ActiveRecord::RecordNotFound) }
  #    end

  #    context 'when resource_id is missing' do
  #      it { expect { make_removed_traits_request(since: 100) }.to raise_error(ActionController::UrlGenerationError) }
  #    end
  #  end
  #end

  #describe '#new_metadata' do
  #  def make_new_metadata_request(req_params)
  #    get :new_metadata, params: req_params, format: :csv
  #  end

  #  def expect_new_metadata_response(req_params, expected_file)
  #    expect_response(:new_metadata, req_params, expected_file)
  #  end

  #  context 'when publish_metadata file is present' do
  #    before do
  #      FileUtils.copy_entry(META_SOURCE, resource_dir.join('publish_metadata.tsv'))
  #    end

  #    context 'when request is valid' do
  #      let(:timestamp1) { 100 }
  #      let(:timestamp2) { 200 }

  #      # TODO: DRY
  #      context 'when there is no trait file in the resource directory' do
  #        it do
  #          make_new_metadata_request(resource_id: resource_id, since: 100)
  #          expect(response).to have_http_status(:no_content)
  #        end
  #      end

  #      context 'when there are no new traits' do
  #        before do
  #          FileUtils.copy_entry(TRAIT_SOURCE1, resource_dir.join("publish_traits_#{timestamp1}.tsv"))
  #          FileUtils.copy_entry(TRAIT_SOURCE1, resource_dir.join("publish_traits_#{timestamp2}.tsv"))
  #        end

  #        it { expect_new_metadata_response({ resource_id: resource_id, since: 150}, EXPECTED_EMPTY_NEW_METADATA_FILE) }
  #      end

  #      context 'when resource.has_persistent_trait_pks is false' do
  #        before do
  #          FileUtils.mkdir(resource_no_diffs_dir)
  #          FileUtils.copy_entry(TRAIT_SOURCE1, resource_no_diffs_dir.join("publish_traits_#{timestamp1}.tsv"))
  #          FileUtils.copy_entry(TRAIT_SOURCE2, resource_no_diffs_dir.join("publish_traits_#{timestamp2}.tsv"))
  #          FileUtils.copy_entry(META_SOURCE, resource_no_diffs_dir.join('publish_metadata.tsv'))
  #        end

  #        it { expect_new_metadata_response({ resource_id: resource_no_diffs_id, since: 150 }, META_SOURCE) }

  #        after do
  #          FileUtils.remove_dir(resource_no_diffs_dir)
  #        end
  #      end

  #      context 'when there are new traits' do
  #        context 'when all files are timestamped' do let(:ignore_timestamp1) { 50 }
  #          let(:ignore_timestamp2) { 170 }

  #          # TODO: DRY
  #          before do
  #            FileUtils.copy_entry(TRAIT_SOURCE1, resource_dir.join("publish_traits_#{timestamp1}.tsv"))
  #            FileUtils.copy_entry(TRAIT_SOURCE2, resource_dir.join("publish_traits_#{timestamp2}.tsv"))

  #            # these should be ignored by implementation -- just create some extra files to ensure the correct ones are used
  #            FileUtils.touch(resource_dir.join("publish_traits_#{ignore_timestamp1}.tsv"))
  #            FileUtils.touch(resource_dir.join("publish_traits_#{ignore_timestamp2}.tsv"))
  #          end

  #          context "when 'since' is absent" do
  #            it { expect_new_metadata_response({ resource_id: resource_id }, META_SOURCE) }
  #          end

  #          context "when 'since' is between most recent timestamp and a previous one" do
  #            it { expect_new_metadata_response({ resource_id: resource_id, since: 150 }, EXPECTED_NEW_METADATA_DIFF_FILE) }
  #          end

  #          context "when 'since' is before earliest timestamp" do
  #            it { expect_new_metadata_response({ resource_id: resource_id, since: 10 }, META_SOURCE) }
  #          end

  #          context "when 'since' is after most recent timestamp" do
  #            it do
  #              make_new_metadata_request({ resource_id: resource_id, since: 300 })
  #              expect(response).to have_http_status(:no_content)
  #            end
  #          end
  #        end

  #        context 'when there is a non-timestamped published_traits.tsv file present' do
  #          context 'when it is the only file' do
  #            before do
  #              FileUtils.copy_entry(TRAIT_SOURCE2, resource_dir.join('publish_traits.tsv'))
  #            end

  #            it { expect_new_metadata_response({ resource_id: resource_id, since: 100 }, META_SOURCE) }
  #          end

  #          context 'when there are also timestamped files' do
  #            context 'when since is before earliest timestamp' do
  #              before do
  #                FileUtils.copy_entry(SOURCE_DIR.join('publish_traits1.tsv'), resource_dir.join('publish_traits.tsv'))
  #                FileUtils.copy_entry(SOURCE_DIR.join('publish_traits2.tsv'), resource_dir.join('publish_traits_100.tsv'))
  #                FileUtils.touch(SOURCE_DIR.join('publish_traits_50.tsv'))
  #              end

  #              it { expect_new_metadata_response({ resource_id: resource_id, since: 25 }, META_SOURCE) }
  #            end

  #            context 'when since is between most recent and another timestamp' do
  #              before do
  #                FileUtils.copy_entry(SOURCE_DIR.join('publish_traits1.tsv'), resource_dir.join('publish_traits_50.tsv'))
  #                FileUtils.copy_entry(SOURCE_DIR.join('publish_traits2.tsv'), resource_dir.join('publish_traits_100.tsv'))
  #                FileUtils.touch(SOURCE_DIR.join('publish_traits.tsv'))
  #              end

  #              it { expect_new_metadata_response({ resource_id: resource_id, since: 75 }, EXPECTED_NEW_METADATA_DIFF_FILE) }
  #            end
  #          end
  #        end
  #      end
  #    end
  #  end

  #  context 'when there is no publish_metadata file for the resource' do
  #    before do
  #      FileUtils.copy_entry(TRAIT_SOURCE2, resource_dir.join('publish_traits.tsv'))
  #    end

  #    it do 
  #      make_new_metadata_request({ resource_id: resource_id, since: 100 })
  #      expect(response).to have_http_status(:no_content)
  #    end
  #  end
  #  
  #  # TODO: DRY
  #  context 'when request is invalid' do
  #    context 'when resource_id is invalid' do
  #      it { expect { make_new_metadata_request(resource_id: 100, since: 100) }.to raise_error(ActiveRecord::RecordNotFound) }
  #    end

  #    context 'when resource_id is missing' do
  #      it { expect { make_new_metadata_request(since: 100) }.to raise_error(ActionController::UrlGenerationError) }
  #    end
  #  end
  #end

  #after do
  #  Resource.data_dir_path = nil
  #end
end

