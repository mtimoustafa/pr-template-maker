require 'tty-command'
require_relative 'prompter'
require_relative '../templates/form'

module PrMaker
  @@form = nil

  def self.make_pr
    self.check_hub_installed
    self.print_introduction

    template_name = ARGV[0]
    @@form = ::Form.get_form(template_name)

    opts = @@form.run_form
    self.submit_pr(opts) if ::Prompter.prompt.yes?('PR details completed. Submit PR?')
  end

  def self.check_hub_installed
    prompt = ::Prompter.prompt

    if TTY::Command.new(printer: :null).run!('brew list hub').failure?
      prompt.say('This tool requires hub but it was not found.')
      prompt.say('Installing hub from Homebrew...')

      TTY::Command.new.run('brew install hub')

      ::Prompter.print_newline
      prompt.say('Done! Time to make a PR:')
      ::Prompter.print_newline
    end
  end

  def self.print_introduction
    ::Prompter.print_newline
    ::Prompter.announce('===== PR MAKER =====')
    ::Prompter.prompt.say('This will make a PR on your current branch against master/main.')
    ::Prompter.prompt.say('Please make sure that you are in the correct directory, on the')
    ::Prompter.prompt.say('correct branch, and that all your changes are pushed to remote.')
    ::Prompter.print_newline
  end

  def self.submit_pr(opts)
    ::Prompter.announce('Submitting PR...')

    erb = @@form.template_erb
    command = TTY::Command.new(printer: :null)
    base_branch = ARGV[1]

    args = ['hub pull-request']
    args.push('-b', base_branch) unless base_branch.nil?
    args.push('-om', erb.result(binding))

    command.run!(*args) do |out, error|
      ::Prompter.print_error(error) unless error.nil?
    end
  end
end
