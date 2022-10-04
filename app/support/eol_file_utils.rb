# Sure, this could be a module, but then we'd just be sticking its methods on a class.
class EolFileUtils
  class << self
    # EolFileUtils.clear_resource_dir(resource)
    def clear_resource_dir(resource)
      Dir.glob("#{resource.path}/*").each do |file|
        next if File.directory?(file)
        next if File.basename(file).match?(/^\.*$/) # Dotfiles
        next if File.basename(file).match?(/publish_traits.*/) # Because these are diffs
        next if file == resource.meta_xml_filename
        next if File.basename(file) == Resource.logfile_name
        next if File.basename(file) == Resource.lockfile_name

        begin
          File.unlink(file)
        rescue Errno::EBUSY => e
          Rails.logger.error("Failed to remove file, possible NFS problem: #{e.message}")
        end
      end
    end

    # EolFileUtils.remove_dot_files(dir)
    def remove_dot_files(dir)
      Dir.glob("#{dir}/.*").each do |file|
        next if File.basename(file).match?(/^\.*$/)

        begin
          File.unlink(file)
        rescue Errno::EBUSY => e
          Rails.logger.error("Failed to remove file: #{e.message}")
        end
      end
    end

    # EolFileUtils.flatten_dirs(dir)
    def flatten_dirs(dir)
      Dir.glob("#{dir}/*").each do |subdir|
        next unless File.directory?(subdir)

        flatten_dirs(subdir)
        EolFileUtils.remove_dot_files(subdir) # We don't want them.
        Dir.glob("#{subdir}/*").each do |subfile|
          puts "Moving #{subfile} to #{dir}"
          FileUtils.mv(subfile, dir)
        end
        begin
          FileUtils.rm_rf(subdir, secure: true)
        rescue Errno::ENOTEMPTY
          Rails.logger.warn("Unable to remove #{subdir} because it was not empty. Please clean up.")
        end
      end
    end
  end
end
