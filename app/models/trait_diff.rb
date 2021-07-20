require 'csv'
require 'set'

class TraitDiff
  attr_reader :new_traits_path
  
  def initialize(resource, since)
    @resource = resource
    @since = since
    @new_traits_path = nil
    @removed_traits_path = nil
    @new_metadata_path = nil

    create_or_read_files
  end

  # don't need metadata_deletes_since because clients should delete metadata along with traits
  
  private
  def create_or_read_files
    trait_files = Dir.glob('publish_traits*.tsv', base: @resource.path)&.sort

    return unless trait_files.any? # all paths stay nil, as they should -- this resource either doesn't have any traits or it hasn't been published yet

    last_published_file = nil

    trait_files.each do |filename|
      timestamp = timestamp_from_filename(filename)

      if timestamp < @since
        last_published_file = filename
      end
    end

    most_recent_file = trait_files[-1]

    if last_published_file != most_recent_file
      create_diff_dir_if_needed
      time1 = timestamp_from_filename(last_published_file)
      time2 = timestamp_from_filename(most_recent_file)
      write_files(last_published_file, most_recent_file, time1, time2)
    end
  end

  def create_diff_dir_if_needed
    FileUtils.mkdir(diff_dir_path) unless File.exist?(diff_dir_path)
  end

  def diff_dir_path
    @resource.path.join('diffs')
  end

  def timestamp_from_filename(filename)
    filename.split('.')[0].split('_')[-1]&.to_i
  end

  def write_files(last_published_file, most_recent_file, time1, time2)
    @new_traits_path = diff_dir_path.join("new_traits_#{time1}_#{time2}.csv")
    @removed_traits_path = diff_dir_path.join("removed_traits_#{time1}_#{time2}.csv")

    return if File.exist?(@new_traits_path) && File.exist?(@removed_traits_path) # Something is corrupted if just one exists, so assume we need to recreate both

    puts "last_published: #{last_published_file}"
    puts "most_recent: #{most_recent_file}"
    
    file1_pks = Set.new
    CSV.foreach(@resource.path.join(last_published_file), headers: true) do |row| # tsv extensions are a lie -- everything is a csv
      file1_pks.add(row['eol_pk'])
    end

    puts "file1_pks: #{file1_pks}"

    new_pks = Set.new

    CSV.open(@new_traits_path, 'wb', headers: Publisher::TRAIT_HEADS, write_headers: true) do |new_traits|
      CSV.foreach(@resource.path.join(most_recent_file), headers: true) do |row|
        eol_pk = row['eol_pk']
        new_pks.add(eol_pk)

        unless file1_pks.include?(eol_pk)
          new_traits << row
        end

        file1_pks.delete(eol_pk)
      end
    end

    CSV.open(@removed_traits_path, 'wb', headers: %i[eol_pk], write_headers: true) do |removed_traits|
      file1_pks.each do |pk|
        removed_traits << [pk]
      end
    end
  end
end
