Pry.config.editor = 'nvim'

Pry.commands.alias_command '...', '!!!'

if defined?(PryByebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
end

if defined?(ActiveRecord)
  Pry::Commands.block_command 'db_log', 'Set ActiveRecord logger' do |logger|
    ActiveRecord::Base.logger = Logger.new(eval(logger))
  end
end
