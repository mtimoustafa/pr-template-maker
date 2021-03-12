require 'pastel'
require 'tty-prompt'

module Prompts
  @@pastel = Pastel.new
  @@prompt = TTY::Prompt.new

  def self.all_testing_methods
    {
      'Specs added or updated': 1,
      'Reviewed accessibility (tabbing, screen reader, contrast, etc.)': 2,
      'Manually in Sandbox': 3,
      'Manually in Staging': 4
    }
  end

  def self.print_header(text, optional = '')
    @@prompt.say(@@pastel.green("=== #{text.upcase}"))
  end

  def self.print_newline
    @@prompt.say("\n")
  end

  def self.optional(text, suffix = '')
    text += " " unless text.empty?
    return "#{text}#{@@pastel.dim('(Enter to leave blank)')}"
  end

  def self.prompt_title
    opts = {}

    self.print_header('PR Title')
    @@prompt.say('Provide a general summary of your changes.')

    opts[:title] = @@prompt.ask('Title:', required: true)

    opts[:jira_id] = @@prompt.ask(self.optional('Relevant Jira ticket ID:')) do |id|
      validate_proc = -> (a) { a == '' || a =~ /[A-z]+-[0-9]+/ }
      id.validate(validate_proc, 'Invalid Jira ticket ID')
    end

    unless opts[:jira_id].nil?
      opts[:jira_id].upcase!
      opts[:title] += " [#{opts[:jira_id]}]"
    end

    self.print_newline
    return opts
  end

  def self.prompt_gif
    opts = {}

    self.print_header('GIF Info')
    @@prompt.say('Add a gif that embodies the soul of your PR...or something cool!')

    opts[:gif] = @@prompt.ask(self.optional('GIF link:')) do |url|
      validate_proc = ->(a) { a == '' || a =~ URI::regexp }
      url.validate(validate_proc, 'Invalid URL')
    end

    opts[:gif_caption] = @@prompt.ask('Caption for accessibility:', default: 'Decorative Image') unless opts[:gif].nil?

    self.print_newline
    return opts
  end

  def self.prompt_description
    opts = {}

    self.print_header('Description')
    @@prompt.say('Why is this change required? What problem does it solve?')

    opts[:description] = @@prompt.multiline(self.optional(''))

    self.print_newline
    return opts
  end

  def self.prompt_risks
    opts = {}

    self.print_header('Risks')
    @@prompt.say('What are the potential side effects these changes could result in?')
    @@prompt.say('What steps have been taken to minimize potential post-deployment surprises?')
    @@prompt.say('If there are no risks to be considered, please explain why.')

    opts[:risks] = @@prompt.multiline(self.optional(''))

    self.print_newline
    return opts
  end

  def self.prompt_testing
    opts = {}

    self.print_header('Testing')
    @@prompt.say('Select all methods you used to test these changes.')
    @@prompt.say('"Specs added or updated" and "Manually in Sandbox" should almost always be checked off.')

    opts[:testing_choices] = @@prompt.multi_select('Testing methods:', all_testing_methods, cycle: true)

    self.print_newline
    @@prompt.say('Please describe the steps you took to manually test your changes.')
    @@prompt.say('If no tests were added or modified, please justify.')

    opts[:testing_description] = @@prompt.multiline(self.optional(''))

    self.print_newline
    @@prompt.say('Other considerations:')
    opts[:other_considerations] = @@prompt.multiline(self.optional(''))

    self.print_newline
    return opts
  end

  def self.prompt_screenshots_or_video
    opts = {}

    self.print_header('Screenshots or Video')
    @@prompt.say('If your PR has substantial visual changes, we will create a "Screenshots or Video" section for you in the PR description.')
    @@prompt.say('If so, please upload before/after screenshots or video demonstrating the changes under that section.')
    opts[:has_visual_changes] = @@prompt.yes?('Does your PR have substantial visual changes?', default: false)

    self.print_newline
    return opts
  end

  def self.prompt_deploy_actions
    opts = {}

    self.print_header('Deploy Actions')
    @@prompt.say('Are there any actions that need to be done after the PR is merged or after it is deployed?')
    @@prompt.say(@@pastel.italic('Example: Update an environment variable in Vault, run a task, update documentation...'))

    opts[:deploy_actions] = @@prompt.multiline(self.optional(''))

    self.print_newline
    return opts
  end

  def self.prompt_blockers
    opts = {}

    self.print_header('Blockers')
    @@prompt.say('If this PR is blocked, please provide a short explanation as to why.')
    @@prompt.say('This may help someone give insight on how to remove said blockers!')

    opts[:blockers] = @@prompt.multiline(self.optional(''))

    self.print_newline
    return opts
  end

  def self.prompt_future_plans
    opts = {}

    self.print_header('Future Plans')
    @@prompt.say('Any plans to improve or iterate on the changes made in this PR?')

    opts[:future_plans] = @@prompt.multiline(self.optional(''))

    self.print_newline
    return opts
  end
end
