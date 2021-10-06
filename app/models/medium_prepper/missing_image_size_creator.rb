module MediumPrepper
  class MissingImageSizeCreator
    def initialize(medium, expected_sizes, size_creator)
      @medium = medium
      @expected_sizes = expected_sizes
      @size_creator = size_creator
    end

    def create_missing_sizes
      parsed_sizes = JSON.parse(@medium.sizes)
      new_sizes = {}

      @expected_sizes.each do |size|
        next if parsed_sizes.include?(size)
        new_sizes[size] = @size_creator.create_size(size)
      end

      if new_sizes.any?
        @medium.update_sizes(new_sizes)
      end
    end
  end
end

