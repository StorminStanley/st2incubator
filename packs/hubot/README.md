# Hubot Integration Pack

Pack that provides management/integration with Hubot

## Assumptions

This pack assumes a few things about Hubot:

* It is being managed in some way via the OS init daemon
* Hubot is cloned via git upstream from a master repository,
  stored locally at /opt/hubot/hubot

This pack will remain in the incubator until we solve the following
in a portable way

* Deployments
* Variable Hubot Location


## Actions

```
+---------------+-------+---------+---------------------------------------------------+
| ref           | pack  | name    | description                                       |
+---------------+-------+---------+---------------------------------------------------+
| hubot.branch  | hubot | branch  | Determine which branch Hubot is currently running |
| hubot.deploy  | hubot | deploy  | Manage Hubot installs on a per-pack basis         |
| hubot.restart | hubot | restart | Restart hubot                                     |
+---------------+-------+---------+---------------------------------------------------+
```
