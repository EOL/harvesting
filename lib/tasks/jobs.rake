def safe_job(job)
  begin
    yield(job)
  rescue
    puts "##{job.id}: #{job.handler[0..73]}.gsub(/\s+/, ' ')}"
  end
end

namespace :jobs do
  desc 'Harvest the last resource (by ID)'
  task q: :environment do
    puts "--\nHARVESTING (#{Delayed::Job.where(queue: 'harvest', failed_at: nil).count} jobs):"
    Delayed::Job.where(queue: 'harvest', failed_at: nil).each do |job|
      safe_job(job) do
        lock = "RUNNING on #{job.locked_by}  <---- " || 'pending'
        h = YAML.load(job.handler)
        klass = h.class.name
        rid = h&.resource_id
        res = rid ? Resource.find(rid).name : 'no resource'
        puts "[#{res}](https://beta-repo.eol.org/resources/#{rid}): #{klass} #{lock}"
      end
    end
    count = Delayed::Job.where(queue: 'media', failed_at: nil).count
    puts "\n--\nMEDIA (#{count} jobs)"
    puts 'FIRST TEN ONLY:' if count > 10
    Delayed::Job.where(queue: 'media', failed_at: nil).limit(10).each do |job|
      safe_job(job) do
        lock = job.locked_by || 'pending'
        h = YAML.load(job.handler)
        klass = h.class.name
        mid = h&.medium_id
        med = mid ? Medium.find(mid).source_url : 'no medium'
        puts "[#{klass}](#{med}): #{lock}"
      end
    end
  end
end
