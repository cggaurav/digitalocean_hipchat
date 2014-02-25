## Digital Ocean Droplet Notifications for HipChat

Fetches information on droplets from Digital Ocean and notifies a HipChat room when something has changed.

## How to use

Copy config.yml.sample to config.yml and add your Digital Ocean and HipChat API keys.

Then run

	$ ruby droplet-notifications.rb

Requires Ruby version >2.0

## Todo

[ ] Notify creation/destruction of droplets
[ ] Write tests
[ ] Convert to daemon
[ ] Convert to rubygem 