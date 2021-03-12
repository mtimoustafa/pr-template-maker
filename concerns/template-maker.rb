require 'erb'
require 'tty-command'
require_relative 'prompts'

module TemplateMaker
  def self.make_template
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

    command.run('echo', erb.result(binding))

    # TODO: check if hub is installed
    # command.run('hub pull-request -m', erb.result(binding))
  end
end
