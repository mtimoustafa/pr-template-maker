require 'pastel'
require 'tty-prompt'

module Prompter
  @@pastel = Pastel.new
  @@prompt = TTY::Prompt.new

  def self.prompt
    @@prompt
  end

  def self.pastel
    @@pastel
  end

  def self.announce(text)
    @@prompt.say(@@pastel.green(text))
  end

  def self.print_header(text, optional = '')
    @@prompt.say(@@pastel.green("=== #{text.upcase}"))
  end

  def self.print_newline
    @@prompt.say("\n")
  end

  def self.print_error(text)
    @@prompt.say(@@pastel.red(text))
  end

  def self.optional(text)
    text += " " unless text.empty?
    return "#{text}#{@@pastel.dim('(Enter to leave blank)')}"
  end
end
