module ResourcesHelper
  def currently_harvesting?(resource)
    Delayed::Job.where(queue: 'harvest').where('locked_at IS NOT NULL').any? do |job|
      job_is_for_resource?(job, resource)
    end
  end

  def job_is_for_resource?(job, resource)
    po = job.payload_object
    return false if po.nil?
    if po.respond_to?(:resource_id)
      po.resource_id == resource.id
    elsif po.is_a?(Resource)
      po.id == resource.id
    end
  end
end
