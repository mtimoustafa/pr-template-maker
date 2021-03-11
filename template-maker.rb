#!/usr/bin/ruby

require 'erb'
require 'tty-command'

command = TTY::Command.new
erb = ERB.new(File.read('./template.md.erb'))

template_options = {
  :name => 'Mohamed'
}

# TODO: check if hub is installed
# command.run('hub pull-request -F')
command.run('echo', erb.result(binding))
