# AppDynamics Agent Installation

The purpose of this puppet manifest is to install the AppDynamics APP Agent and the AppDynamics MACHINE Agent.

Note that while this manifest *installs* the agents, it does not *enable* them.  To actually enable either agent, view the source of the script to see an example of how to run it, and then execute it directly from the server's command line (while manually logged in).  Scripts should be placed at `/home/ec2-user`.

## Background

As of Mar 23, 2015, it was understood that additional AppDynamics agents cost money.  Therefore, rather than globally enable every server with AppDynamics, we can manually enable select servers with AppDynamics.

## Programatically Enabling the Agents

The included scripts can eaisly be called programmatically like any other bash command.
