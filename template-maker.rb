#!/usr/bin/ruby

require 'erb'
require 'tty-command'
require 'tty-prompt'
require 'uri'

command = TTY::Command.new
prompt = TTY::Prompt.new
erb = ERB.new(File.read('./template.md.erb'))

all_testing_choices = {
  'Specs added or updated': 1,
  'Reviewed accessibility (tabbing, screen reader, contrast, etc.)': 2,
  'Manually in Sandbox': 3,
  'Manually in Staging': 4
}

template_opts = prompt.collect do
  # title
  prompt.say('== title')
  prompt.say('provide a general summary of your changes')

  key(:title).ask('title:', required: true)

  prompt.say('does this relate to an issue in jira? if so, please include the ticket id:')

  key(:jira_id).ask('jira id:') do |id|
    validate_proc = -> (a) { a == '' || a =~ /[a-z]+-[0-9]+/ }
    id.validate(validate_proc, "sorry, this isn't a valid jira id :(")
  end

  # gif
  prompt.say('== GIF')
  prompt.say('add a gif that embodies the soul of your pr... or something cool!')

  key(:gif).ask('gif url:') do |url|
    validate_proc = ->(a) { a == '' || a =~ uri::regexp }
    url.validate(validate_proc, "sorry, this isn't a valid url :(")
  end

  key(:gif_caption).ask('gif caption (for accessibility!)', default: 'decorative image') unless key(:gif).nil?

  # description
  prompt.say('== DESCRIPTION')
  prompt.say('why is this change required? what problem does it solve?')
  prompt.say('describe your changes and solution in detail')

  key(:description).multiline('')

  # risks
  prompt.say('== RISKS')
  prompt.say('what are the potential side effects these changes could result in?')
  prompt.say('what steps have been taken to minimize potential post-deployment surprises?')
  prompt.say('if there are no risks to be considered, please explain why.')

  key(:risks).multiline('')

  # Testing
  prompt.say('== TESTING')
  prompt.say('Check off the methods you used to test these changes (by placing an "x" inside the brackets)')
  prompt.say('"Specs added or updated" and "Manually in Sandbox" should almost always be checked off')

  key(:testing_choices).multi_select('Please select all that apply:', all_testing_choices, cycle: true)

  prompt.say('Please describe the steps you took to manually test your changes.')
  prompt.say('If no tests were added or modified, please justify')
  key(:testing_description).multiline('')

  # Other considerations
  key(:other_considerations).multiline('Other considerations:')

  # Screenshots or video
  prompt.say('== SCREENSHOTS OR VIDEO')
  prompt.say('If your PR has substantial visual changes, we will create a "Screenshots or Video" section for you in the PR description.')
  prompt.say('Please include before/after screenshots or video demonstrating the changes and upload them under that section.')
  key(:has_visual_changes).yes?('Does your PR have substantial visual changes?')

  # Deploy actions
  prompt.say('== DEPLOY ACTIONS')
  prompt.say('Are there any actions that need to be done after the PR is merged or after it is deployed?')
  prompt.say('Example: Update an environment variable in Vault, Run a task, Update (API) documentation')
  
  key(:deploy_actions).multiline('')

  # Blockers
  prompt.say('== BLOCKERS')
  prompt.say('If this PR is blocked, please provide a short explanation as to why.')
  prompt.say('This may help someone give insight on how to remove said blockers.')

  key(:blockers).multiline('')

  # Future plans
  prompt.say('== FUTURE PLANS')
  prompt.say('Any plans to improve or iterate on the changes made in this PR?')

  key(:future_plans).multiline('')
end

unless template_opts[:jira_id].nil?
  template_opts[:jira_id].upcase!
  template_opts[:title] += " [#{template_opts[:jira_id]}]"
end

command.run('echo', erb.result(binding))

# TODO: check if hub is installed
command.run('hub pull-request -m', erb.result(binding))
