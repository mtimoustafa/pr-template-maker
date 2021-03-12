require 'erb'
require 'tty-command'
require_relative 'form'
require_relative 'prompter'

module PrMaker
  def self.make_pr
    self.check_hub_installed

    command = TTY::Command.new
    erb = ERB.new(File.read('./templates/template.md.erb'))
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

    # TODO: remove echo and uncomment live command
    command.run('echo', erb.result(binding))
    # command.run('hub pull-request -m', erb.result(binding))
  end

  def self.check_hub_installed
    prompt = ::Prompter.prompt

    if TTY::Command.new(printer: :null).run('hub --version').failure?
      prompt.say('This tool requires hub but it was not found.')
      prompt.say('Installing hub from Homebrew...')

      TTY::Command.new.run('brew install hub')

      ::Prompter.print_newline
      prompt.say('Done! Time to make a PR:')
      ::Prompter.print_newline
    end
  end
end
