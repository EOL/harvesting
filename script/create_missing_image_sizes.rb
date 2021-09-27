RESUME_FILE_PATH = Rails.root.join('tmp', 'resume_create_missing_image_sizes.txt')

def read_resume_file
  id = 0

  if File.exist?(RESUME_FILE_PATH)
    File.open(RESUME_FILE_PATH) do |f|
      puts "reading id from file #{resume_file_path} to resume"
      id = Integer(f.gets.strip)
    end
  end

  id
end

def write_resume_file(id)
  File.open(RESUME_FILE_PATH, 'w') do |f|
    f.write(id)
  end
end

gt_id = read_resume_file
media = Medium.where(format: :jpg).where('id > ?', gt_id)
total = media.count
count = 0

puts "creating missing image sizes for #{total} jpg media"

media.find_each do |medium|
  medium.create_missing_image_sizes
  count += 1
  write_resume_file(medium.id) if count % 100 == 0
  puts "processed #{count} so far" if count % 1000 == 0
end

File.unlink(RESUME_FILE_PATH) if File.exist?(RESUME_FILE_PATH)
puts "done"

