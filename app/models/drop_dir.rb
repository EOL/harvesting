class DropDir
  class << self
    def check
      Rails.logger.info('DropDir.check')
      path = Rails.public_path.join('data', 'drop')
      FileUtils.mkdir_p(path) unless Dir.exist?(path)
      resources = []
      Dir.glob("#{path}/*").each do |file| # NOTE: file is a full path, now.
        resources << pickup_file(file)
      end
    end

    def pickup_file(file, resource = nil)
      (basename, abbr, ext) = parse_name(file)
      dir = unpack_file(file, basename: basename, abbr: abbr, ext: ext)
      resource = Resource.find_by_abbr(abbr) if Resource.exists?(abbr: abbr)
      if resource
        resource.updated_files!
        false
      elsif File.exist?("#{dir}/meta.xml")
        resource = Resource.from_xml(dir)
        Rails.logger.info("DropDir: will harvest resource #{resource.name} (#{resource.id})")
        resource.enqueue_harvest
        true
      else
        # TODO: we can assume it's an Excel and write a .from_excel method much like .from_xml...
        Rails.logger.error("DropDir: New Resource (#{dir}), but no meta.xml. Cannot proceed!")
        false
      end
    end

    def parse_name(file)
      ext = File.extname(file)
      basename = File.basename(file, ext)
      abbr = shorten(basename)
      [basename, abbr, ext]
    end

    def unpack_file(file, options = {})
      basename = options[:basename]
      abbr = options[:abbr]
      ext = options[:ext]
      (basename, abbr, ext) = DropDir.parse_name(file) unless basename && abbr && ext
      dir = Rails.public_path.join('data', abbr.gsub(/\s+/, '_'))
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      if ext.casecmp('.tgz').zero?
        untgz(file, dir)
      elsif ext.casecmp('.tar.gz').zero?
        untgz(file, dir)
      elsif ext.casecmp('.zip').zero?
        unzip(file, dir)
      else
        Rails.logger.error("DropDir: I don't know how to handle a #{ext}: #{basename}#{ext}")
        raise("Cannot extract #{basename}#{ext}")
      end
      flatten_dirs(dir)
      remove_dot_files(dir)
      File.unlink(file) # If we've gotten this far, we've extracted it. Now remove it.
      dir
    end

    def shorten(basename)
      abbr = basename.dup
      return abbr if abbr.size <= 16
      elements = abbr.split(/[^A-Za-z0-9]/)
      if elements.size > 2
        temp = elements.shift[0..3] + '-'
        final = elements.pop[0..3]
        # NOTE: 16 - 5 (four chrs plus a sep) = 11
        while !elements.empty? && (temp.size + final.size <= 11)
          temp += "#{elements.shift[0..3]}-"
        end
        abbr = temp + final
      elsif elements.size > 1
        abbr = "#{elements.first[0..7]}-#{elements.last[0..6]}"
      else
        if matches = abbr.scan(/^(.*)(\d+)$/).first
          name = matches.first
          digits = matches.last
          allowed_size = 15 - digits.size
          name = name[0..allowed_size]
          abbr = "#{name}-#{digits}"
        end
      end
      abbr[0..15]
    end

    def untgz(file, dir)
      res = `cd #{dir} && tar xvzf #{file}`
    end

    def unzip(file, dir)
      # NOTE: -u for "update and create if necessary"
      # NOTE: -q for "quiet"
      # NOTE: -o for "overwrite files WITHOUT prompting"
      res = `cd #{dir} && unzip -quo #{file}`
    end

    def remove_dot_files(dir)
      Dir.glob("#{dir}/.*").each do |file|
        next if File.basename(file).match?(/^\.*$/)
        File.unlink(file)
      end
    end

    def flatten_dirs(dir)
      Dir.glob("#{dir}/*").each do |subdir|
        next unless File.directory?(subdir)
        flatten_dirs(subdir)
        Dir.glob("#{subdir}/*").each do |subfile|
          puts "Moving #{subfile} to #{dir}"
          FileUtils.mv(subfile, dir)
        end
        FileUtils.rmdir(subdir)
      end
    end
  end
end
