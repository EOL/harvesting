require 'prometheus/client'


# returns a default registry
prometheus = Prometheus::Client.registry

# Just some very basic stuff for testing:
RESOURCE_REQUESTS = prometheus.counter(:resource_requests, docstring: 'A counter of resource requests made')
