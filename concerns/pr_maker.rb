require 'erb'
require 'tty-command'
require_relative 'form'
require_relative 'prompter'

module PrMaker
  def self.make_pr
    self.check_hub_installed
    self.print_introduction

    opts = {}
    opts.merge!(::Form.prompt_title)
    opts.merge!(::Form.prompt_gif)
    opts.merge!(::Form.prompt_description)
    opts.merge!(::Form.prompt_risks)
    opts.merge!(::Form.prompt_testing)
    opts.merge!(::Form.prompt_screenshots_or_video)
    opts.merge!(::Form.prompt_deploy_actions)
    opts.merge!(::Form.prompt_blockers)
    opts.merge!(::Form.prompt_future_plans)

    self.submit_pr(opts)
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
    ::Prompter.prompt.say('Please make sure that you are on the correct branch')
    ::Prompter.prompt.say('and that all your changes are pushed to remote.')
    ::Prompter.print_newline
  end

  def self.submit_pr(opts)
    ::Prompter.announce('Submitting PR...')

    erb = ERB.new(File.read('./templates/template.md.erb'), nil, '-')
    command = TTY::Command.new(printer: :null)

    command.run!('hub pull-request -om', erb.result(binding)) do |out, error|
      ::Prompter.print_error(error) unless error.nil?
    end
  end
end
