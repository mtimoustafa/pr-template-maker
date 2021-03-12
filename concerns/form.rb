require_relative 'prompter'

module Form
  def self.all_testing_methods
    {
      'Specs added or updated': 1,
      'Reviewed accessibility (tabbing, screen reader, contrast, etc.)': 2,
      'Manually in Sandbox': 3,
      'Manually in Staging': 4
    }
  end

  def self.prompt_title
    opts = {}

    ::Prompter.print_header('PR Title')
    ::Prompter.prompt.say('Provide a general summary of your changes.')

    opts[:title] = ::Prompter.prompt.ask('Title:', required: true)

    opts[:jira_id] = ::Prompter.prompt.ask(::Prompter.optional('Relevant Jira ticket ID:')) do |id|
      validate_proc = -> (a) { a == '' || a =~ /[A-z]+-[0-9]+/ }
      id.validate(validate_proc, 'Invalid Jira ticket ID')
    end

    unless opts[:jira_id].nil?
      opts[:jira_id].upcase!
      opts[:title] += " [#{opts[:jira_id]}]"
    end

    ::Prompter.print_newline
    return opts
  end

  def self.prompt_gif
    opts = {}

    ::Prompter.print_header('GIF Info')
    ::Prompter.prompt.say('Add a gif that embodies the soul of your PR...or something cool!')

    opts[:gif] = ::Prompter.prompt.ask(::Prompter.optional('GIF link:')) do |url|
      validate_proc = ->(a) { a == '' || a =~ URI::regexp }
      url.validate(validate_proc, 'Invalid URL')
    end

    opts[:gif_caption] = ::Prompter.prompt.ask('Caption for accessibility:', default: 'Decorative Image') unless opts[:gif].nil?

    ::Prompter.print_newline
    return opts
  end

  def self.prompt_description
    opts = {}

    ::Prompter.print_header('Description')
    ::Prompter.prompt.say('Why is this change required? What problem does it solve?')

    opts[:description] = ::Prompter.prompt.multiline(::Prompter.optional(''))

    ::Prompter.print_newline
    return opts
  end

  def self.prompt_risks
    opts = {}

    ::Prompter.print_header('Risks')
    ::Prompter.prompt.say('What are the potential side effects these changes could result in?')
    ::Prompter.prompt.say('What steps have been taken to minimize potential post-deployment surprises?')
    ::Prompter.prompt.say('If there are no risks to be considered, please explain why.')

    opts[:risks] = ::Prompter.prompt.multiline(::Prompter.optional(''))

    ::Prompter.print_newline
    return opts
  end

  def self.prompt_testing
    opts = {}

    ::Prompter.print_header('Testing')
    ::Prompter.prompt.say('Select all methods you used to test these changes.')
    ::Prompter.prompt.say('"Specs added or updated" and "Manually in Sandbox" should almost always be checked off.')

    opts[:testing_choices] = ::Prompter.prompt.multi_select('Testing methods:', all_testing_methods, cycle: true)

    ::Prompter.print_newline
    ::Prompter.prompt.say('Please describe the steps you took to manually test your changes.')
    ::Prompter.prompt.say('If no tests were added or modified, please justify.')

    opts[:testing_description] = ::Prompter.prompt.multiline(::Prompter.optional(''))

    ::Prompter.print_newline
    ::Prompter.prompt.say('Other considerations:')
    opts[:other_considerations] = ::Prompter.prompt.multiline(::Prompter.optional(''))

    ::Prompter.print_newline
    return opts
  end

  def self.prompt_screenshots_or_video
    opts = {}

    ::Prompter.print_header('Screenshots or Video')
    ::Prompter.prompt.say('If your PR has substantial visual changes, we will create a "Screenshots or Video" section for you in the PR description.')
    ::Prompter.prompt.say('If so, please upload before/after screenshots or video demonstrating the changes under that section.')
    opts[:has_visual_changes] = ::Prompter.prompt.yes?('Does your PR have substantial visual changes?', default: false)

    ::Prompter.print_newline
    return opts
  end

  def self.prompt_deploy_actions
    opts = {}

    ::Prompter.print_header('Deploy Actions')
    ::Prompter.prompt.say('Are there any actions that need to be done after the PR is merged or after it is deployed?')
    ::Prompter.prompt.say(::Prompter.pastel.italic('Example: Update an environment variable in Vault, run a task, update documentation...'))

    opts[:deploy_actions] = ::Prompter.prompt.multiline(::Prompter.optional(''))

    ::Prompter.print_newline
    return opts
  end

  def self.prompt_blockers
    opts = {}

    ::Prompter.print_header('Blockers')
    ::Prompter.prompt.say('If this PR is blocked, please provide a short explanation as to why.')
    ::Prompter.prompt.say('This may help someone give insight on how to remove said blockers!')

    opts[:blockers] = ::Prompter.prompt.multiline(::Prompter.optional(''))

    ::Prompter.print_newline
    return opts
  end

  def self.prompt_future_plans
    opts = {}

    ::Prompter.print_header('Future Plans')
    ::Prompter.prompt.say('Any plans to improve or iterate on the changes made in this PR?')

    opts[:future_plans] = ::Prompter.prompt.multiline(::Prompter.optional(''))

    ::Prompter.print_newline
    return opts
  end
end
