class PublishDiff < ApplicationRecord
  belongs_to :resource
  validates_presence_of :resource_id, :t1, :t2, :status

  Timestamps = Struct.new(:t1, :t2)

  enum status: {
    pending: 0,
    enqueued: 1,
    processing: 1,
    completed: 2,
    failed: 3
  }

  class << self
    def since(resource, time)
      timestamps = timestamps_from_files(resource, time)

      if timestamps && timestamps.t1 && timestamps.t2
        self.create_with(status: :pending)
          .find_or_create_by!(
            t1: timestamps.t1,
            t2: timestamps.t2,
            resource: resource
          )
      else
        if timestamps&.t2
          new_trait_file = "publish_traits_#{timestamps.t2}.tsv"
        else
          new_trait_file = 'publish_traits.tsv'
        end

        self.new(
          status: :completed,
          remove_all_traits: true,
          new_traits_path: resource.path.join(new_trait_file),
          removed_traits_path: nil,
          new_metadata_path: resource.path.join("publish_metadata.tsv")
        )
      end
    end

    private
    def timestamps_from_files(resource, since_time)
      trait_files = Dir.glob('publish_traits*.tsv', base: resource.path)

      # all paths stay nil, as they should -- this resource either doesn't have any traits or it hasn't been harvested
      # yet
      return unless trait_files.any?

      last_harvested_timestamp = nil
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
        end

        if (
          (last_harvested_timestamp.nil? || timestamp > last_harvested_timestamp) &&
          since_time.present? &&
          timestamp < since_time
        )
          last_harvested_timestamp = timestamp
        end
      end

      if last_harvested_timestamp.present? || most_recent_timestamp.present?
        t1 = resource.can_perform_trait_diffs? ? last_harvested_timestamp : nil

        Timestamps.new(t1, most_recent_timestamp)
      else
        nil
      end
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
  end

  def perform
    trait_file1 = resource_file_path(t1)
    trait_file2 = resource_file_path(t2)

    create_diff_dir_if_needed

    new_traits_path = diff_dir_path.join("new_traits_#{t1}_#{t2}.csv")
    removed_traits_path = diff_dir_path.join("removed_traits_#{t1}_#{t2}.csv")
    new_metadata_path = diff_dir_path.join("new_metadata_#{t1}_#{t2}.csv")

    file1_pks = Set.new
    CSV.foreach(trait_file1, headers: true) do |row| # tsv extensions are a lie -- everything is a csv
      file1_pks.add(row['eol_pk'])
    end

    new_pks = Set.new
    CSV.open(new_traits_path, 'wb', headers: Publisher::TRAIT_HEADS, write_headers: true) do |new_traits|
      CSV.foreach(trait_file2, headers: true) do |row|
        eol_pk = row['eol_pk']

        unless file1_pks.include?(eol_pk)
          new_traits << row
          new_pks.add(eol_pk)
        end

        file1_pks.delete(eol_pk)
      end
    end

    if file1_pks.any?
      CSV.open(removed_traits_path, 'wb', headers: %i[eol_pk], write_headers: true) do |removed_traits|
        file1_pks.each do |pk|
          removed_traits << [pk]
        end
      end

      self.removed_traits_path = removed_traits_path
    end

    publish_meta_path = resource.publish_table_path('metadata')
    any_new_metas = false
    if File.exist?(publish_meta_path)
      CSV.open(new_metadata_path, 'wb', headers: Publisher::META_HEADS, write_headers: true) do |new_metas|
        CSV.foreach(publish_meta_path, headers: true) do |row|
          # is_external metadata are always 'new' -- there's no notion of diffs for them.
          # Assume client will remove all existing before republish.
          if new_pks.include?(row['trait_eol_pk']) || row['is_external'] == 'true'
            new_metas << row
            any_new_metas = true
          end
        end
      end
    end

    if new_pks.any?
      self.new_traits_path = new_traits_path
    elsif File.exist?(new_traits_path)
      FileUtils.rm(new_traits_path)
    end

    if any_new_metas
      self.new_metadata_path = new_metadata_path
    elsif File.exist?(new_metadata_path)
      FileUtils.rm(new_metadata_path)
    end

    self.status = :completed
    self.save!
  end
  handle_asynchronously :perform, queue: :publish_diffs


  private
  def resource_file_path(time)
    resource.path.join("publish_traits_#{time}.tsv")
  end

  def diff_dir_path
    resource.path.join('diffs')
  end

  def create_diff_dir_if_needed
    FileUtils.mkdir(diff_dir_path) unless File.exist?(diff_dir_path)
  end
end
