module JobsTask
  def self.safe_job(job)
    bits = []
    # I don't want to modify Rails's eager_load_paths just to allow this, so:
    job.handler.scan(/ruby\/object:(\S+)/).each do |array|
      klass = array.first
      next if klass.match?(/^Active/)
      next if klass.match?(/^Delayed/)
      require Rails.root.join('app', 'models', "#{klass.underscore}.rb")
    end
    h = YAML.load(job.handler)
    if h.respond_to?(:resource_id)
      res = Resource.find(h.resource_id)
      bits << "[#{res.name}](https://beta-repo.eol.org/resources/#{res.id})"
    end
    if h.respond_to?(:method_name)
      bits << ".#{h.method_name}"
    end
    if h.respond_to?(:id)
      bits << "id=#{h.id}"
    end
    if h.respond_to?(:medium_id)
      mid = h&.medium_id rescue nil
      med = mid ? Medium.find(mid).source_url : 'no medium'
      bits << "[Medium.find(#{mid})](#{med})"
    end
    what = if h.respond_to?(:display_name)
      h.display_name
    else
      job.handler[0..64].gsub(/\s+/, ' ')
    end
    bits << what
    bits << "RUNNING on #{job.locked_by}  <---- " || 'pending'
    puts "job = Delayed::Job.find(#{job.id}): #{bits.join(' ')}"
  end
end

namespace :jobs do
  desc 'Harvest the last resource (by ID)'
  task :q => :environment do
    puts "--\nHARVESTING (#{Delayed::Job.where(queue: 'harvest', failed_at: nil).count} jobs):"
    Delayed::Job.where(queue: 'harvest', failed_at: nil).each do |job|
      JobsTask.safe_job(job)
    end
    count = Delayed::Job.where(queue: 'media', failed_at: nil).count
    puts "\n--\nMEDIA (#{count} jobs)"
    puts 'FIRST TEN ONLY:' if count > 10
    Delayed::Job.where(queue: 'media', failed_at: nil).limit(10).each do |job|
      JobsTask.safe_job(job)
    end
  end
end
