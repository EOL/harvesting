require 'rails_helper'

RSpec.describe('MediumPrepper::ImageSizeCreator') do
  describe '#create_size' do
    let(:medium) { instance_double('Medium') }
    let(:orig_image) { instance_double('Magick::Image') }
    let(:new_image) { instance_double('Magick::Image') }
    let(:dir) { 'medium_dir' }
    let(:basename) { 'medium_basename' }
    let!(:file_utils) { class_double('FileUtils').as_stubbed_const }

    before do
      allow(medium).to receive(:jpg?) { true }
      allow(medium).to receive(:dir) { dir }
      allow(medium).to receive(:basename) { basename }
      allow(new_image).to receive(:columns) { new_cols }
      allow(new_image).to receive(:rows) { new_rows }
      expect(new_image).to receive(:strip!)
      expect(new_image).to receive(:write).with(expected_filename)
      expect(new_image).to receive(:destroy!)
      expect(file_utils).to receive(:chmod).with(0o644, expected_filename)
    end

    shared_examples_for 'creates sized image' do
      it do
        creator = MediumPrepper::ImageSizeCreator.new(medium, orig_image)
        expect(creator.create_size(size)).to eq("#{new_cols}x#{new_rows}")
      end
    end

    context 'when width == height' do
      let(:size) { '50x50' }
      let(:resized_image) { instance_double('Magick::Image') }
      let(:new_cols) { 50 }
      let(:new_rows) { 50 }
      let(:expected_filename) { 'medium_dir/medium_basename.50x50.jpg' }

      before do
        expect(orig_image).to receive(:resize_to_fill).with(50, 50) { resized_image }
        expect(resized_image).to receive(:crop).with(Magick::NorthWestGravity, 50, 50) { new_image }
      end

      it_behaves_like 'creates sized image'
    end

    context 'when width != height' do
      let(:size) { '300x200' }
      let(:new_cols) { 300 }
      let(:new_rows) { 180 }
      let(:expected_filename) { 'medium_dir/medium_basename.300x200.jpg' }

      before do
        expect(orig_image).to receive(:resize_to_fit).with(300, 200) { new_image }
      end

      it_behaves_like 'creates sized image'
    end
  end
end
