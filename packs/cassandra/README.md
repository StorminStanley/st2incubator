# Cassandra Integration Pack

This StackStorm Cassandra pack provides integrations for Apache Cassandra.

## Actions

`nodetool` - StackStorm nodetool wrapper that simply executes nodetool command on a remote host (Connects to remote host via SSH and runs the nodetool command).

`is_seed_node` - Check if a supplied ``node_id`` is part of ``seeds`` in Cassandra config file. Prints True/False as output. Requires pyyaml to be installed on the remote box running Cassandra. This is a remote script action i.e. StackStorm uses SSH to connect to remote box and executes the script.

`list_seed_nodes` - Prints all the seed nodes from all seed providers in Cassandra config file. Prints a comma separated list of nodes as output (delimiter can be changed by supplying a param to action). This is a remote script action i.e. StackStorm uses SSH to connect to remote box and executes the script. Requires pyyaml to be installed on the remote box running Cassandra.

`clear_cass_data` - Removes Cassandra data dir on remote box. Dangerous!!!

`stop_dse` - Stops DSE cassandra service on an ubuntu box (uses upstart).

`start_dse` - Stops DSE cassandra service on an ubuntu box (uses upstart).

`get_dse_status` - Gets DSE cassandra service status from an ubuntu box (uses upstart).

`replace_host` - Workflow that replaces a given `dead_node` with a `replacement_node`.
