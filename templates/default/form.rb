require 'erb'
require_relative '../../concerns/prompter'

module DefaultForm
  def self.run_form
    return self.prompt_form
  end

  def self.template_erb
    template_path = File.join(File.dirname(__FILE__), './template.md.erb')
    ERB.new(File.read(template_path), trim_mode: '-')
  end

  def self.prompt_form
    opts = {}

    ::Prompter.print_header('PR Information')

    opts[:title] = ::Prompter.prompt.ask('Title:', required: true)

    ::Prompter.prompt.say('Description:')
    opts[:description] = ::Prompter.prompt.multiline(::Prompter.optional(''))

    ::Prompter.print_newline
    return opts
  end
end
