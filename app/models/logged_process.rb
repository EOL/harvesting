# Lets you run a bunch of steps with proper logging, resume, and status updates.
class LoggedProcess
  def initialize(resource)
    @resource = resource
    @process = HarvestProcess.create(resource_id: @resource.id)
    @log = resource.process_log
    @start_time = Time.now
    starting("logged process")
  end

  def run_step(method_name = nil)
    method_name ||= '(unnammed proc)'
    if @resource.skips&.split(',')&.include?(method_name.to_s)
      warn("Skipping #{method_name} for this resource.")
      return nil
    end
    starting(method_name)
    begin
      yield # NOTE: rescue handled higher up.
    ensure
      stopping(method_name)
    end
  end

  def in_groups(set, group_size, options = {})
    size = options.key?(:size) ? options[:size] : set.size
    groups = (size.to_f / group_size).ceil
    info("Processing group of #{size} in #{groups} groups of #{group_size}")
    @process.in_group_of_size(groups)
    start_all = Time.now
    begin
      models.in_groups_of(group_size, false) do |group|
        start = Time.now
        yeild group
        @process.tick_group((Time.now - start).round(2))
      end
    ensure
      log_times(@process.finished_group, start_all)
    end
  end

  def in_batches(set, batch_size, options = {})
    size = options.key?(:size) ? options[:size] : set.size
    num_batches = (size.to_f / batch_size).ceil
    info("Processing group of #{size} in #{num_batches} batches of #{batch_size}")
    @process.in_group_of_size(num_batches)
    start_all = Time.now
    begin
      set.find_in_batches(batch_size: batch_size) do |group|
        start = Time.now
        yeild group
        @process.tick_group((Time.now - start).round(2))
      end
    ensure
      log_times(@process.finished_group, start_all)
    end
  end

  # Up to the caller to call @process.update_group(position, time)
  def enter_group(size = nil)
    @process.in_group_of_size(size) if size
    yield(@process)
    @process.finished_group
  end

  def log_times(times, start_all)
    info("Finished processing, times: #{times.join(', ')}")
    info("Average: #{times.sum.to_f / times.size}")
    info("Time: #{(Time.now - start_all).round(2)}")
    return unless times.size > 6
    first_set = times[0..2].sum.to_f / 3
    last_set = times[-3..-1].sum.to_f / 3
    info("Slope: #{(last_set / first_set).round(2)}")
  end

  def exit
    took = (Time.now - @start_time).round(2)
    stopping("logged process, took #{took}")
    @process.update_attribute(:method_breadcrumbs, 'EXITED')
    took
  end

  def info(message)
    @log.tagged('INFO') { log(message) }
    @log.flush
  end

  def warn(message)
    @log.tagged('WARN') { log(message) }
    @log.flush
  end

  def starting(method_name)
    @log.tagged('START') { log(method_name) }
    @log.flush
    @process.start(method_name)
  end

  def cmd(command)
    @log.tagged('CMD') { log(command) }
    @log.flush
  end

  def stopping(method_name)
    @log.tagged('STOP') { log(method_name) }
    @log.flush
    @process.stop(method_name)
  end

  def fail(e)
    error("#{e.class.name}")
    error("#{e.message&.gsub(/#<(\w+):0x[0-9a-f]+>/, '\\1')}")
    # Custom exceptions may not have a backtrace:
    if e.backtrace
      e.backtrace.each do |trace|
        stopwords = ['pry', 'delayed_job.rb', 'bundler', 'script', 'ruby', 'gems', '.rbenv']
        next if stopwords.any? { |word| trace.match?(/\b#{word}\b/) }
        trace.gsub!(%r{#{Rails.root}}, '.') # Remove website path..
        error(trace)
      end
    end
  end

  def error(message)
    @log.tagged('ERR') { log(message) }
    @log.flush
  end

  def log(message)
    @log.warn("[#{Time.now.strftime('%F %T')}] #{message}")
  end
end
