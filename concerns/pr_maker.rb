require 'tty-command'
require_relative 'prompter'
require_relative '../templates/form'

module PrMaker
  @@form = nil

  def self.make_pr
    self.check_gh_installed
    self.print_introduction

    template_name = ARGV[0]
    @@form = ::Form.get_form(template_name)

    opts = @@form.run_form
    self.submit_pr(opts[:title]) if ::Prompter.prompt.yes?('PR details completed. Submit PR?')
  end

  def self.check_gh_installed
    prompt = ::Prompter.prompt

    if TTY::Command.new(printer: :null).run!('brew list gh').failure?
      prompt.say('This tool requires GitHub CLI but it is not installed.')
      prompt.say('Installing "gh" from Homebrew...')

      TTY::Command.new.run('brew install')

      ::Prompter.print_newline
      prompt.say('Done! Time to make a PR.')
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

  def self.submit_pr(title)
    ::Prompter.announce('Submitting PR...')

    pr_body = @@form.template_erb
    command = TTY::Command.new(printer: :null)
    base_branch = ARGV[1]
    puts base_branch

    args = ['gh pr create']
    args.push('-B', base_branch) unless base_branch.nil?
    args.push('-t', title)
    args.push('-wb', pr_body)

    command.run!(*args) do |out, error|
      ::Prompter.print_error(error) unless error.nil?
    end
  end
end
