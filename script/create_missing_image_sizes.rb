total = Medium.where(format: :jpg).count
count = 0

puts "creating missing image sizes for #{total} jpg media"

Medium.where(format: :jpg).find_each do |medium|
  medium.create_missing_image_sizes
  count += 1
  puts "processed #{count} so far" if count % 1000 == 0
end

puts "done"

