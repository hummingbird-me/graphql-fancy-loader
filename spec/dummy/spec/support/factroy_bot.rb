require 'factory_bot'

# Explicitly load the dummy app's factory definitions. (factory_bot_rails' railtie
# auto-discovery doesn't reliably pick them up from the dummy app's nested spec dir.)
FactoryBot.definition_file_paths = [Rails.root.join('spec', 'factories').to_s]
FactoryBot.find_definitions

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
