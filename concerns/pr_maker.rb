require 'erb'
require 'tty-command'
require 'tty-prompt'
require_relative 'prompts'

module PrMaker
  def self.make_pr
    self.check_hub_installed

    command = TTY::Command.new
    erb = ERB.new(File.read('./templates/template.md.erb'))
    opts = {}

    opts.merge!(::Prompts.prompt_title)
    opts.merge!(::Prompts.prompt_gif)
    opts.merge!(::Prompts.prompt_description)
    opts.merge!(::Prompts.prompt_risks)
    opts.merge!(::Prompts.prompt_testing)
    opts.merge!(::Prompts.prompt_screenshots_or_video)
    opts.merge!(::Prompts.prompt_deploy_actions)
    opts.merge!(::Prompts.prompt_blockers)
    opts.merge!(::Prompts.prompt_future_plans)

    # TODO: remove echo and uncomment live command
    @@command.run('echo', erb.result(binding))
    # @@command.run('hub pull-request -m', erb.result(binding))
  end

  def self.check_hub_installed
    prompt = TTY::Prompt.new

    if TTY::Command.new(printer: :null).run('hub --version').failure?
      prompt.say('This tool requires hub but it was not found.')
      prompt.say('Installing hub from Homebrew...')

      TTY::Command.new.run('brew install hub')

      prompt.say("\n")
      prompt.say('Done! Time to make a PR:')
      prompt.say("\n")
    end
  end
end
