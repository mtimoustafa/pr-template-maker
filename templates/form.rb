require_relative 'default/form'
require_relative 'example/form'

module Form
  def self.get_form(template_name)
    case template_name
    when 'example'
      return ::ExampleForm
    else
      return ::DefaultForm
    end
  end
end
