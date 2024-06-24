class HarvestProcess < ApplicationRecord
  establish_connection Rails.env.to_sym
  belongs_to :resource, inverse_of: :harvest_processes

  def in_group_of_size(size)
    Admin.check_connection
    update_attribute(:current_group_size, size)
    update_attribute(:current_group_times, '')
    update_attribute(:current_group, 1)
  end

  def tick_group(time)
    record_time(time)
    update_attribute(:current_group, current_group + 1)
  end

  def record_time(time)
    Admin.check_connection
    if current_group_times.blank?
      update_attribute(:current_group_times, time)
    else
      update_attribute(:current_group_times, "#{current_group_times},#{time}")
    end
  end

  def update_group(position, time = nil)
    Admin.check_connection
    record_time(time) if time
    update_attribute(:current_group, position)
  end

  def finished_group
    return [] if current_group_times.nil?
    Admin.check_connection
    all_times = current_group_times.split(/,/).map(&:to_f)
    update_attribute(:current_group_size, 0)
    update_attribute(:current_group_times, '')
    update_attribute(:current_group, 0)
    all_times
  end

  def start(method_name)
    if method_breadcrumbs.blank?
      update_attribute(:method_breadcrumbs, method_name)
    else
      update_attribute(:method_breadcrumbs, "#{method_breadcrumbs},#{method_name}")
    end
  end

  def stop(method_name)
    return if method_breadcrumbs.blank?
    breadcrumbs = method_breadcrumbs.split(',')
    return unless breadcrumbs.include?(method_name.to_s)
    breadcrumbs.delete(method_name.to_s)
    Admin.check_connection
    update_attribute(:method_breadcrumbs, breadcrumbs.join(','))
  end
end
