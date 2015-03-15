#!/usr/bin/env ruby

require 'rubygems'
require 'uri'
require 'json'

message = ARGV
commands   = []
parameters = {}
defaults   = {
  'branch'     => 'master',
  'subtree'    => true,
  'role'       => 'localhost',
  'debug'      => false,
  'info'       => false,
  'delete'     => false,
  'force'      => false,
}

# Break up the message into commands vs parameters
message.each do |w|
  if w =~ /=/
    p = w.split('=')
    parameters[p[0]] = p[1].gsub(/['"]/, '')
  else
    # Only collect commands before parameters are entered.
    # It's garbage otherwise
    commands << w if parameters.empty?
  end
end

# Make sure this is a pack deployment
unless commands.include?('pack')
  puts "This is not a pack deployment command."
  exit 1
end

# Let's now see if we can suss out what the user wants.
# Should address a few uses...
#   Use 1: !deploy pack rackspace from StackStorm/st2incubator
#   - pack: rackspace, repo: https://github.com/StackStorm/st2incubator, subtree = true
#   Use 2: !deploy pack StackStorm/rackspace
#   - pack: rackspace, repo: https://github.com/StackStorm/rackspace, subtree = false
#   Use 3: !deploy pack https://bitbucket.com/StackStorm/rackspace
#   - pack: rackspace, repo: https://bitbucket.com/StackStorm/rackspace

# Grab the pack
parameters['pack'] = commands[2].include?('/') ? commands[2].split('/')[1] : commands[2]

# Determine array index for repo target
irepo = commands.include?('from') ? 4 : 2

case commands[irepo]
# Let's also make sure that the repo target is what we expect (org/repo)
when /^\w+\/\w+$/
  parameters['repo'] = 'https://github.com/' + commands[irepo]
# or is a valid URI target
when URI::regexp
  parameters['repo'] = commands[irepo]
else
  parameters['repo'] = 'https://github.com/StackStorm/st2contrib'
end

# And toggle off tree traversal if standalone repo
parameters['subtree'] = false if irepo == 2

payload = {
  'commands'   => commands,
  'parameters' => defaults.merge(parameters),
}

puts payload.to_json
