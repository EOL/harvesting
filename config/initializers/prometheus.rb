require 'prometheus/client'
require 'prometheus/client/rack/collector'
require 'prometheus/client/rack/exporter'

# Create a default registry
Prometheus::Client.registry = Prometheus::Client::Registry.new

# Just some very basic stuff for testing:
RESOURCE_REQUESTS = Prometheus::Client.registry.counter(
  :harvesting_resource_requests_total,
  docstring: 'A counter of resource requests',
  labels: [:abbr]
)

RESOURCE_RENDER_DURATION = Prometheus::Client.registry.histogram(
  :harvesting_resource_query_seconds,
  docstring: 'Page render duration for resources',
  labels: [:abbr]
)

# Add basic app metrics
Rails.application.middleware.use Prometheus::Client::Rack::Collector
Rails.application.middleware.use Prometheus::Client::Rack::Exporter