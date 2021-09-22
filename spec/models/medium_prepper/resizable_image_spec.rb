require 'rails_helper'

RSpec.describe MediumPrepper::ResizableImage do
  describe '#prep_medium' do 
    describe 'success pathway' do
      let(:medium) { instance_double('Medium') }
      let(:medium_class) { class_double('Medium').as_stubbed_const }
      let(:raw) { instance_double('File') }
      let(:raw_path) { 'raw_path' }
      let(:magick_image_class) { class_double('Magick::Image').as_stubbed_const }
      let(:magick_image) { instance_double('Magick::Image') }
      let(:medium_dir) { 'medium_dir' }
      let(:medium_basename) { 'medium_basename' }
      let(:file_class) { double('File') }
      let(:file_utils_class) { class_double('FileUtils').as_stubbed_const }
      let(:orig_filename) { 'medium_dir/medium_basename.jpg' }
      let(:quality) { 60 }
      let(:columns) { 2000 }
      let(:rows) { 1000 }
      let(:size1) { '100x100' }
      let(:size2) { '500x300' }
      let(:size1_filename) { 'medium_dir/medium_basename.100x100.jpg' }
      let(:size2_filename) { 'medium_dir/medium_basename.500x300.jpg' }
      let(:size1_image) { instance_double('Magick::Image') }
      let(:size1_columns) { 100 }
      let(:size1_rows) { 70 }
      let(:size1_intermediate) { instance_double('Magick::Image') }
      let(:size2_image) { instance_double('Magick::Image') }
      let(:size2_columns) { 500 }
      let(:size2_rows) { 275 }
      let(:time_class) { class_double('Time').as_stubbed_const }
      let(:now) { 123456789 }
      let(:default_base_url) { 'default_base_url' }
      let(:resource) { instance_double('Resource') }
      let(:downloaded_media_count) { 20 }

      def setup_sized_image(image, size, filename, rows, cols)
        expect(image).to receive(:columns) { cols }
        expect(image).to receive(:rows) { rows }
        expect(image).to receive(:strip!)
        expect(image).to receive(:write).with(filename)
        expect(image).to receive(:destroy!)
        expect(file_utils_class).to receive(:chmod).with(0o644, filename)
      end

      before do
        allow(time_class).to receive(:now) { now }
        allow(medium).to receive(:default_base_url) { default_base_url }
        allow(medium).to receive(:resource) { resource }
        allow(resource).to receive(:downloaded_media_count) { downloaded_media_count }
        expect(resource).to receive(:update_attribute).with(:downloaded_media_count, downloaded_media_count + 1)
        expect(raw).to receive(:respond_to?).with(:to_io) { true } 
        expect(raw).to receive(:path) { raw_path }
        expect(magick_image_class).to receive(:read) { [magick_image] }
        expect(magick_image).to receive(:format=).with('JPEG')
        expect(magick_image).to receive(:auto_orient)
        expect(magick_image).to receive(:destroy!)
        allow(medium).to receive(:dir) { medium_dir }
        allow(medium).to receive(:basename) { medium_basename }
        expect(file_class).to receive(:exist?).with(orig_filename) { false }
        expect(magick_image).to receive(:write).with(orig_filename)
        expect(file_utils_class).to receive(:chmod).with(0o644, orig_filename)
        expect(magick_image).to receive(:columns) { columns }
        expect(magick_image).to receive(:rows) { rows }
        expect(medium_class).to receive(:sizes) { [size1, size2] }
        expect(magick_image).to receive(:resize_to_fill).with(100, 100) { size1_intermediate }
        expect(size1_intermediate).to receive(:crop).with(Magick::NorthWestGravity, 100, 100) { size1_image }
        setup_sized_image(size1_image, size1, size1_filename, size1_rows, size1_columns)
        expect(magick_image).to receive(:resize_to_fit).with(500, 300) { size2_image }
        setup_sized_image(size2_image, size2, size2_filename, size2_rows, size2_columns)
        expect(medium).to receive(:update_attributes).with({
          sizes: JSON.generate({
            'original' => '2000x1000',
            '100x100' => '100x70',
            '500x300' => '500x275'
          }),
          w: columns,
          h: rows,
          downloaded_at: now,
          unmodified_url: 'default_base_url.jpg',
          base_url: default_base_url
        })
      end

      subject(:prepper) { MediumPrepper::ResizableImage.new(medium, raw, file_class) }

      it 'meets expectations' do
        prepper.prep_medium
      end
    end
  end
end
