require 'csv'
require 'set'

class TraitDiff
  def initialize(resource, since)
    @resource = resource
    @since = since
    @new_traits_path = nil
    @removed_traits_path = nil
    @new_metadata_path = nil
    @valid = true

    create_or_read_files
  end

  def new_traits_path
    raise TypeError, "TraitDiff invalid" unless valid?
    @new_traits_path
  end

  def removed_traits_path
    raise TypeError, "TraitDiff invalid" unless valid?
    @removed_traits_path
  end

  def new_metadata_path
    raise TypeError, "TraitDiff invalid" unless valid?
    @new_metadata_path
  end

  def valid?
    @valid
  end

  # don't need metadata_deletes_since because clients should delete metadata along with traits
  
  private
  # TODO: break up method
  def create_or_read_files
    trait_files = Dir.glob('publish_traits*.tsv', base: @resource.path)

    return unless trait_files.any? # all paths stay nil, as they should -- this resource either doesn't have any traits or it hasn't been published yet

    last_published_file = nil
    last_published_timestamp = nil
    most_recent_file = nil
    most_recent_timestamp = nil
    earliest_timestamp = nil

    trait_files.each do |filename|
      timestamp = timestamp_from_filename(filename)

      next unless timestamp.present?

      if earliest_timestamp.nil? || timestamp < earliest_timestamp
        earliest_timestamp = timestamp
      end

      if most_recent_timestamp.nil? || timestamp > most_recent_timestamp
        most_recent_timestamp = timestamp
        most_recent_file = filename
      end

      if (
        (last_published_timestamp.nil? || timestamp > last_published_timestamp) &&
        @since.present? &&
        timestamp < @since
      )
        last_published_timestamp = timestamp
        last_published_file = filename
      end
    end

    if (
      @since.present? && 
      last_published_file.present? && 
      last_published_file != most_recent_file   
    )
      create_diff_dir_if_needed
      time1 = timestamp_from_filename(last_published_file)
      time2 = timestamp_from_filename(most_recent_file)
      write_files(last_published_file, most_recent_file, time1, time2)
    else
      most_recent_file = trait_files[-1] if most_recent_file.nil?
      @new_traits_path = @resource.path.join(most_recent_file)
      publish_meta_path = @resource.publish_table_path(:metadata)
      @new_metadata_path = publish_meta_path if File.exist?(publish_meta_path) # Otherwise, leave it nil
      write_remove_all_traits_file
    end
  end

  def create_diff_dir_if_needed
    FileUtils.mkdir(diff_dir_path) unless File.exist?(diff_dir_path)
  end

  def diff_dir_path
    @resource.path.join('diffs')
  end

  def timestamp_from_filename(filename)
    # format of timestamped file is publish_traits_<timestamp>.tsv
    parts = filename.split('.')[0].split('_')
    
    if parts.length == 3
      parts[2].to_i
    else # assume non-timestamped file, e.g., legacy publish_traits.tsv
      nil
    end
  end

  def write_files(last_published_file, most_recent_file, time1, time2)
    @new_traits_path = diff_dir_path.join("new_traits_#{time1}_#{time2}.csv")
    @removed_traits_path = diff_dir_path.join("removed_traits_#{time1}_#{time2}.csv")
    @new_metadata_path = diff_dir_path.join("new_metadata_#{time1}_#{time2}.csv")

    # Something is corrupted if some but not all exist, so assume we need to recreate them
    if (
      File.exist?(@new_traits_path) && 
      File.exist?(@removed_traits_path) &&
      File.exist?(@new_metadata_path)
    )
      return
    end

    file1_pks = Set.new
    CSV.foreach(@resource.path.join(last_published_file), headers: true) do |row| # tsv extensions are a lie -- everything is a csv
      file1_pks.add(row['eol_pk'])
    end

    new_pks = Set.new
    CSV.open(@new_traits_path, 'wb', headers: Publisher::TRAIT_HEADS, write_headers: true) do |new_traits|
      CSV.foreach(@resource.path.join(most_recent_file), headers: true) do |row|
        eol_pk = row['eol_pk']

        unless file1_pks.include?(eol_pk)
          new_traits << row
          new_pks.add(eol_pk)
        end

        file1_pks.delete(eol_pk)
      end
    end

    CSV.open(@removed_traits_path, 'wb', headers: %i[eol_pk], write_headers: true) do |removed_traits|
      file1_pks.each do |pk|
        removed_traits << [pk]
      end
    end

    CSV.open(@new_metadata_path, 'wb', headers: Publisher::META_HEADS, write_headers: true) do |new_metas|
      publish_meta_path = @resource.publish_table_path(:metadata)
      if File.exist?(publish_meta_path)
        CSV.foreach(publish_meta_path, headers: true) do |row|
          new_metas << row if new_pks.include?(row['trait_eol_pk'])
        end
      end
    end
  end

  def write_remove_all_traits_file
    @removed_traits_path = @resource.path.join('remove_all_traits.csv')

    return if File.exist?(@removed_traits_path)

    CSV.open(@removed_traits_path, 'wb', headers: %i[eol_pk], write_headers: true) do |csv|
      csv << ['*']
    end
  end
end
