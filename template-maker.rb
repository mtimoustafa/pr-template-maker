#!/usr/bin/ruby

require 'tty-command'

command = TTY::Command.new
command.run('git pull')
