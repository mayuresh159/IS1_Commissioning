## Launch and Deployments

### Launch Delay

On initialization the FSW starts a launch delay counter.  When the counter expires, the
FSW takes the following actions:

* Enable UHF radio telemetry stream
* Deploy un-deployed components
* Start deployment timer

Once the s/c has launched and the initial long delay has elapsed, ground
should send a command to set the delay to zero to prevent another delay upon
s/c reset.

### Deployables

There are three deployable components:

* Solar Panel 1
* Solar Panel 2
* UHF Antenna

There are flags stored in flash that record if the component is deployed or not.
Every time the deployment timer expires, FSW will activate the deployment mechanism 
for all of the un-deployed components.

Ground must send commands to make a component as deployed, the FSW does not try to
determine the status on its own.

The deployment mechanism is active for 20 seconds and then FSW autonomously deactivates it.

### Parameters

The following is a summary of the parameters related to launch and deployments:

* Launch delay time - number of seconds to delay
* Deployment Status - indicates which components are deployed
* Deploy interval time - seconds between deployment attempts

### Commands

The following is a summary of the commands related to launch:

* cmd_mode_launch_delay - set launch delay interval
* cmd_mode_launch_set_flag - sets launch delay complete flag (not saved in flash)
* cmd_mode_deploy_interval - sets deployment interval
* cmd_mode_deploy_flag - sets deployment status flag

### Telemetry

The following is a summary of the telemetry related to launch:

* mode_deployables - deployment status flags
* mode_launch_delay - launch delay time
* mode_launch_count - launch delay counter
* mode_launch_flag - launch delay complete flag
* mode_deploy_int - deployment interval
* mode_deploy_count - deployment interval counter

