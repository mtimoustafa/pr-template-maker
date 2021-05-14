require 'erb'
require 'uri'
require_relative '../../concerns/prompter'

module ExampleForm
  def self.run_form
    opts = {}

    opts.merge!(self.required_example)
    opts.merge!(self.validation_example)
    opts.merge!(self.multiline_example)
    opts.merge!(self.multi_select_example)
    opts.merge!(self.yes_no_example)

    return opts
  end

  def self.template_erb
    template_path = File.join(File.dirname(__FILE__), './template.md.erb')
    ERB.new(File.read(template_path), trim_mode: '-')
  end

  def self.required_example
    opts = {}

    ::Prompter.print_header('PR Title')
    ::Prompter.prompt.say('Provide a general summary of your changes.')

    opts[:title] = ::Prompter.prompt.ask('Title:', required: true)

    ::Prompter.print_newline
    return opts
  end

  def self.validation_example
    opts = {}

    ::Prompter.print_header('GIF Info')
    ::Prompter.prompt.say('Add a cool gif to your PR!')

    opts[:gif] = ::Prompter.prompt.ask(::Prompter.optional('GIF link:')) do |url|
      validate_proc = ->(a) { a == '' || a =~ URI::regexp }
      url.validate(validate_proc, 'Invalid URL')
    end

    ::Prompter.print_newline
    return opts
  end

  def self.multiline_example
    opts = {}

    ::Prompter.print_header('Description')
    ::Prompter.prompt.say('Describe your changes and their impact:')

    opts[:description] = ::Prompter.prompt.multiline(::Prompter.optional(''))

    ::Prompter.print_newline
    return opts
  end

  def self.multi_select_example
    opts = {}

    ::Prompter.print_header('Testing')

    opts[:testing_choices] = ::Prompter.prompt.multi_select('Testing methods:', testing_methods, cycle: true)

    ::Prompter.print_newline
    return opts
  end

  def self.yes_no_example
    opts = {}

    ::Prompter.print_header('UI impact')
    opts[:has_visual_changes] = ::Prompter.prompt.yes?('Does your PR impact the UI?', default: false)

    ::Prompter.print_newline
    return opts
  end

  def self.testing_methods
    {
      'Locally tested': 1,
      'Tested in Staging': 2
    }
  end
end
