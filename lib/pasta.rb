# Implements the copypasta commands

module Pasta
  extend Discordrb::Commands::CommandContainer

  command(:c,
          description: 'Prints a copypasta',
          usage: '<pasta to print>',
          min_args: 1,
          max_args: 1) do |event, *args|
    pasta = args[0].to_sym

  end
end
