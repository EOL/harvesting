module JobsTask
  def self.safe_job(job)
    begin
      yield(job)
    rescue
      # I don't want to modify Rails's eager_load_paths just to allow this, so:
      job.handler.scan(/ruby\/object:(\S+)/).each do |array|
        klass = array.first
        next if klass.match?(/^Active/)
        next if klass.match?(/^Delayed/)
        require Rails.root.join('app', 'models', "#{klass.underscore}.rb")
      end
      h = YAML.load(job.handler)
      bits = []
      if h.respond_to?(:resource_id)
        res = Resource.find(h.resource_id)
        bits << "[#{res.name}](https://beta-repo.eol.org/resources/#{res.id})"
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
end

namespace :jobs do
  desc 'Harvest the last resource (by ID)'
  task :q => :environment do
    # Rails.configuration.eager_load_paths += "#{Rails.configuration.root}/app/models"

    puts "--\nHARVESTING (#{Delayed::Job.where(queue: 'harvest', failed_at: nil).count} jobs):"
    Delayed::Job.where(queue: 'harvest', failed_at: nil).each do |job|
      JobsTask.safe_job(job) do
        lock = "RUNNING on #{job.locked_by}  <---- " || 'pending'
        h = YAML.load(job.handler)
        klass = h.class.name
        rid = h&.resource_id rescue nil
        res = rid ? Resource.find(rid).name : 'no resource'
        puts "[#{res}](https://beta-repo.eol.org/resources/#{rid}): #{klass} #{lock}"
      end
    end
    count = Delayed::Job.where(queue: 'media', failed_at: nil).count
    puts "\n--\nMEDIA (#{count} jobs)"
    puts 'FIRST TEN ONLY:' if count > 10
    Delayed::Job.where(queue: 'media', failed_at: nil).limit(10).each do |job|
      JobsTask.safe_job(job) do
        lock = job.locked_by || 'pending'
        h = YAML.load(job.handler)
        klass = h.class.name
        mid = h&.medium_id rescue nil
        med = mid ? Medium.find(mid).source_url : 'no medium'
        puts "[#{klass}](#{med}): #{lock}"
      end
    end
  end
end
