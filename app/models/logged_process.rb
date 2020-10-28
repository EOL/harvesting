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
      set.in_groups_of(group_size, false) do |group|
        start = Time.now
        yield group
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
        yield group
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
    # info("Finished processing, times: #{times.join(', ')}")
    info("Average Time: #{(times.sum.to_f / times.size).round(3)}")
    info("Total Time: #{time_in_human_readable_breakdown(Time.now - start_all)}")
    return unless times.size > 6
    first_set = times[0..2].sum.to_f / 3
    last_set = times[-3..-1].sum.to_f / 3
    info("last 3 / first 3: #{(last_set / first_set).round(2)}")
    info("Std.Dev: #{std_dev(times)}; Max: #{times.max}")
  end

  def time_in_human_readable_breakdown(tot_sec)
    sec = tot_sec % 60
    mins  = tot_sec / 60 % 60
    hours = tot_sec / (60 * 60) % 60
    days  = tot_sec / (60 * 60 * 24) % 24
    tot_time = "#{sec.ceil}s"
    tot_time = "#{mins.floor}m#{tot_time}" if mins > 1
    tot_time = "#{hours.floor}h#{tot_time}" if hours > 1
    tot_time = "#{days.floor}d#{tot_time}" if days > 1
    tot_time
  end

  # TODO: If we ever want a standard deviation elsewhere, we should generalize this...
  def std_dev(times)
    mean = times.sum / times.size
    sum = times.inject(0) { |accum, i| accum + (i - mean)**2 }
    sample_variance = (sum / (times.size - 1)).round(3)
    Math.sqrt(sample_variance)
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

  def debug(message)
    @log.tagged('DEBUG') { log(message) }
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
