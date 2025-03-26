require 'prometheus/client'


# returns a default registry
prometheus = Prometheus::Client.registry

Prometheus::Client::Counter.new(:http_requests, docstring: 'A counter of HTTP requests made')

# Just some very basic stuff for testing:
RESOURCE_REQUESTS = prometheus.counter(
  :http_requests, docstring: 'A counter of HTTP requests made',
  labels: [:abbr]
)
