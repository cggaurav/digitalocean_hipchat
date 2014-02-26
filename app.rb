require 'open-uri'
require 'json'
require 'yaml'

config = YAML.load_file('config.yml')

# Convert the watched properties from strings to symbols
$watched_properties = config["watched_properties"].map &:to_sym

# Takes an old and new state and returns a hash describing the changes.
#
# Sample state:
#
# => {359165=>{:name=>"production_old", :size_id=>66, :ip_address=>"37.139.15.229", :status=>"active"}}
#
# Sample change:
#
# => {359165=>{:name=>{:old_value=>"production_old", :new_value=>"production_new"}}}
#
def get_changes (old_state, current_state)
  if old_state === current_state
    return nil
  else
    return [old_state, '|', current_state]
  end
end

# Notifies hipchat about each change as described by the get_changes method.
# 
# Sample change:
#
# => {359165=>{:name=>{:old_value=>"production_old", :new_value=>"production_new"}}}
#
$hipchat_uri = "http://api.hipchat.com/v1/rooms/message?format=json&auth_token=#{config["hipchat_token"]}&room_id=#{config["hipchat_room"]}&from=#{config["hipchat_from"]}&notify=#{config["hipchat_notify"]}"

def notify_hipchat (changes)
  message = changes.to_s
  URI.parse(URI.encode($hipchat_uri + "&message=#{message}")).read

  return
end

old_state = {}
do_uri = "https://api.digitalocean.com/droplets/?client_id=#{config["do_client_id"]}&api_key=#{config["do_api_key"]}"

while true do
  data = JSON.parse(URI.parse(do_uri).read)

  current_state = {}

  data["droplets"].each do |droplet|
    current_state[droplet["id"]] = {
      name:     droplet["name"],
      size_id:  droplet["size_id"],
      ip_address: droplet["ip_address"],
      status:   droplet["status"],
    }
  end

  puts current_state
  
  unless old_state.empty?
    changes = get_changes(old_state, current_state)
    if not changes.nil?
      flag = false
      notify_hipchat(changes)
    end
  end
  
  old_state = current_state

  sleep config["poll_interval"]
end