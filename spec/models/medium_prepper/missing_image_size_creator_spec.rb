require 'rails_helper'

RSpec.describe('MediumPrepper::MissingImageSizeCreator') do
  describe('#create_missing_sizes') do
    let(:medium) { instance_double('Medium') }
    let(:expected_sizes) { %w(50x50 100x100 200x100 300x200) }
    let(:cur_sizes) { JSON.generate({ '50x50' => '50x50', '200x100' => '200x78' }) }
    let(:new_sizes) { { '100x100' => '100x100', '300x200' => '300x150' } }
    let(:size_creator) { instance_double('MediumPrepper::ImageSizeCreator') }

    before do
      allow(medium).to receive(:sizes) { cur_sizes }
      expect(medium).to receive(:update_sizes).with(new_sizes)
      expect(size_creator).to receive(:create_size).with('100x100') { '100x100' }
      expect(size_creator).to receive(:create_size).with('300x200') { '300x150' }
    end

    subject(:subject) { MediumPrepper::MissingImageSizeCreator.new(medium, expected_sizes, size_creator) }

    it 'creates the missing sizes and updates the Medium' do
      subject.create_missing_sizes
    end
  end
end

