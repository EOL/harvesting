require 'rails_helper'

PUBLIC_DIR = Rails.root.join('public')

RSpec.describe PublishDiffsController do
  let(:since) { 100 }
  let(:resource) { create(:resource) }

  context 'when resource_id is present and valid' do
    def set_record_status(record, status)
      true_method = status + '?'

      allow(record).to receive(:pending?) { false }
      allow(record).to receive(:processing?) { false }
      allow(record).to receive(:completed?) { false }
      allow(record).to receive(:failed?) { false }
      allow(record).to receive(true_method) { true }
      allow(record).to receive(:status) { status }
    end

    let(:klass) { class_double('PublishDiff').as_stubbed_const }
    let(:record) { instance_double('PublishDiff') }

    before { allow(klass).to receive(:since).with(resource, since) { record } }

    context "when PublishDiff.since returns a 'pending' record" do
      before do
        set_record_status(record, 'pending')
        allow(record).to receive(:perform_with_delay)
      end

      it "responds as expected and calls 'perform_with_delay' on the record" do
        get :show, params: { resource_id: resource.id, since: since }, format: :json
        
        expect(record).to have_received(:perform_with_delay)
        expect(response).to have_http_status(:ok)

        expect(JSON.parse(response.body).symbolize_keys).to eq({
          status: 'pending'
        })
      end
    end

    context "when PublishDiff.since returns a 'completed' record" do
      let(:new_traits_path_rel) { 'resource/new_traits.csv' }
      let(:removed_traits_path_rel) { 'resource/removed_traits.csv' }
      let(:new_metadata_path_rel) { 'resource/new_metadata.csv' }
      let(:new_traits_path) { PUBLIC_DIR.join(new_traits_path_rel) }
      let(:removed_traits_path) { PUBLIC_DIR.join(removed_traits_path_rel) }
      let(:new_metadata_path) { PUBLIC_DIR.join(new_metadata_path_rel) }

      before do
        set_record_status(record, 'completed')
        allow(record).to receive(:new_traits_path) { new_traits_path }
        allow(record).to receive(:removed_traits_path) { removed_traits_path }
        allow(record).to receive(:new_metadata_path) { new_metadata_path }
        allow(record).to receive(:remove_all_traits?) { false }
      end
      
      it "responds with the record's data" do
        get :show, params: { resource_id: resource.id, since: since }, format: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).symbolize_keys).to eq({
          status: 'completed',
          new_traits_path: new_traits_path_rel,
          removed_traits_path: removed_traits_path_rel,
          new_metadata_path: new_metadata_path_rel,
          remove_all_traits: false
        })
      end
    end

    context "when PublishDiff.since returns a 'failed' record" do
      before { set_record_status(record, 'failed') }

      it "responds with status 'failed'" do
        get :show, params: { resource_id: resource.id, since: since }, format: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).symbolize_keys).to eq({
          status: 'failed'
        })
      end
    end

    context "when PublishDiff.since returns a 'processing' record" do
      before { set_record_status(record, 'processing') }

      it "responds with status 'processing'" do
        get :show, params: { resource_id: resource.id, since: since }, format: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).symbolize_keys).to eq({
          status: 'processing'
        })
      end
    end
  end
end

