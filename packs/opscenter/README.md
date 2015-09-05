# Datastax opscenter Integration Pack

This StackStorm Opscenter pack provides integrations to Datastax opscenter product via
opscenter APIs. At the time of writing this pack, http://docs.datastax.com/en/
opscenter/5.1/api/docs/index.html was used.

## Configuration

You'll need to setup base url for opscenter deployment and cluster_id that you want to work with in config.yaml.

```yaml
---
opscenter_base_url: http://myopscenter.mydomain.com:8888
cluster_id: "TestCluster"
```

## Actions

cluster_id in most of these actions are optional and is read from config.yaml. If you are
operating multiple clusters with same opscenter, be sure to explicitly provide the
`cluster_id` argument for the actions.

### General actions
`get-cluster-configs` - Lists configurations of all clusters managed by opscenter.

### Cluster actions

`add-node-to-cluster` - Adds a node to an existing Cassandra cluster.
`launch-ec2-instance-and-add-to-cluster` - Launches an EC2 instance and adds the instance
    to the cluster. Needs both node configuration and ec2 credentials.
`get-cluster-info` - Lists info about specified cluster.
`start-cluster-repair` - Starts repair operation in specified cluster.
`get-repair-status` - Get status of repair operation in specified cluster.
`get-cluster-repair-progress` - Get repair progress for specified cluster.
`restart-cluster` - Restarts the specified cluster.
`get-nodes-info` - Dumps info about all nodes in cluster.
`get-storage-capacity` - Lists info about storage capacity of specified cluster.

### Node actions

For node actions, node_ip argument is mandatory.

`decommission-node` - Decommissions a node from cluster.
`drain-node` - Drains a Cassandra node.
`start-node` - Starts the specified node.
`stop-node` - Stops the specified node.
`restart-node` - Restarts the specified node.
`set-node-conf` - Sets configuration for specified node.
`get-node-conf` - Dumps configuration for specified node.


### Helper actions

`get-request-status` - Some actions return a request id. You can query
    status of request using this action.
`cancel-request` - Cancel a long running request.
`list-requests` - List all outstanding requests for a request type.

## Sensors

`EventsConsumer` - Consumes all events from opscenter and injects them into StackStorm
    with trigger ref as `opscenter.event` and payload as event info. Please see sensors/events_consumer.yaml for event specification.
