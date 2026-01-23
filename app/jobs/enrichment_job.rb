class EnrichmentJob < ApplicationJob
  queue_as :default

  def perform(resource_type, resource_id)
    EnrichmentService.new(resource_type.to_sym, resource_id).call
  end
end
