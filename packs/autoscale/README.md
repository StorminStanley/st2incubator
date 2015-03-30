Cloud Autoscaling
=========

This pack highligts the use of StackStorm in a generic, autoscaling pipeline. This pack comes in a mostly
out-of-the-box setup and can be bootstrapped from https://github.com/StackStorm/showcase-autoscaling. Head
there for rapid setup.

## Overview

The goal of this project is to have a workspace that allows you to develop infrastructure in conjuction
with StackStorm, or even work on the StackStorm product itself. This project also serves as a template
to be used to begin building out and deploying infrastructure using your favorite Configuration Management
tool in conjunction with StackStorm

## Autoscaling Process

There are several reasons to leverage an autoscaling cloud. One of the more common use-cases include adding additional capacity due to a surge in demand or failure of existing resources. This is where we set our sights: How could StackStorm help facilitate the management of additional capacity when needed? So, we broke down the problem into the smallest components, and set our sights on potential solutions. In short, it broke down to a few phases...

* Phase 0: Setting up an autoscaling group
* Phase 1: Systems Failing
* Phase 2: Monitor the Situation
* Phase 3: Recover and Stand Down
* Phase 4: Decommission an autoscaling group

In Phase 1, StackStorm would receive an event from a monitoring system, in this case New Relic. The monitoring system should tell us what application or infrastructure component is impacted, and how it is impacted (is it a warning alert in that the system has some time to respond before things go poorly, or are we already in a critical scenario where immediate action is needed?). From Phase 1, systems are provisioned in order to alleviate pressure. This phase may also include some escalation policies to let folks know of the situation.

Phase 2 deals with attempting to quantify the recovery state of an application. A critical incident may still be underway, but at this point additional resources are allocated to manage the load. During this phase, StackStorm needs to stay on top of things to make sure that if another tipping point is reached with resources that it is ready to provide additional relief as necessary. Likewise, StackStorm needs to be smart enough to know when an event has ceased, and when things can start cooling down.

Phase 3 is all about cleanup. An event is over, and now it's time to return to normal. StackStorm needs to have an understanding of what normal means, and how to safely get there with minimal to no disruption on the part of users.

We started our exploration detailing how we imagined the autoscaling workflow would be executed, and added creation and deletion actions on both ends of the process to ensure completeness. In the interest of brevity, a ton of details have been omitted. Those more inclined to dig into additional details can find more about our thought processes and how we put this together can take a look at https://gist.github.com/jfryman/2345a6c6b1abb312d8cb. The key takeaway though is that we were able to abstractly discuss the logic of how we expected the workflow to run without ever discussing tooling, which in turn allowed us to identify more  This allowed us to better understand what data from our tools that we might need while integrating with the different parts of the stack.

## Architecture and Integrations

At an abstract level, the workflow is very easy. But, the devil is always in the details, and with autoscaling this is doubly so. We needed to break down all the individual components used to create a new system ready to process requests and start building integrations for them. Considering the full lifecycle of a machine, we needed to:

* Provisioning new VMs
* Register a VM with DNS
* Applying configuration profiles to new machines
* Receive notifications that an application is misbehaving
* Receive notifications that an application has recovered
* Add nodes to load balancer
* Remove nodes from load balancer
* Removing a VM from DNS
* Destroying a VM

So, let's walk through how it all works.

![architecture_diagram](https://cloud.githubusercontent.com/assets/20028/6277282/339edbda-b842-11e4-9638-750dda437ab6.jpg)

To begin with, we have a set of actions that is responsible for Phase 0: Setting up a new Auto-Scaling group. This process is responsible for creating a new association within StackStorm, and deciding what flavor/size of cloud compute nodes that will be set-up. These values are all stored in StackStorm's internal datastore. https://github.com/StackStorm/st2incubator/blob/master/packs/autoscale/actions/workflows/asg_create.yaml

Then, we wait. At some point, our application will fail. In our case, we even developed a fun new application that allows us to simulate App and Server errors. New Relic has four events that we're going to keep an eye out for - looking to see if an application or server has entered a critical state, and the corresponding recovery event. These events are sent to StackStorm via NewRelic's WebHook API, and processed as triggers, and then matched to rules like this: https://raw.githubusercontent.com/StackStorm/st2incubator/master/packs/autoscale/rules/newrelic_failure_alert.yaml.

Depending on the received event (Alert/Recovery), things go into action. In the event of a alert, StackStorm will set the alert state for the given application to 'Active'. This is used with the governor which I'll touch upon in a moment. Then, StackStorm jumps into action by kicking off adding as many new nodes to our Autoscale group as we specified at creation. This workflow is responsible for adding additional nodes, making sure they have been provisioned with Chef, and also adding the nodes to DNS and the Load Balancer. Finally, as all of these events fire, we send out ChatOps notifications to Slack to keep all the admins informed about what is happening within StackStorm. This workflow is articulated at https://github.com/StackStorm/st2incubator/blob/master/packs/autoscale/actions/workflows/asg_add_node.yaml.

All the while, another internal sensor that we call a TimerSensor is running, polling every 30 seconds. Each interval, the governor looks at the state of all AutoScale group alert statuses to decide whether or not additional nodes need to be created and added to the autoscale group. It does this by looking for any AutoScale groups that are in alert state, and attempts to add additional capacity if the right conditions are met. A sort of blunt sword throttling is in place for the first pass - the governor evaluates the time since the last scale event and responds accordingly. The same logic happens in reverse, but at a much slower rate (longer duration between deletions, fewer machines destroyed at a time).

