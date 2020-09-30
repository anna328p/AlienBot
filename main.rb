#!/usr/bin/env ruby

require 'discordrb'
require 'fullwidth'
require 'yaml'
require 'figlet'
require 'cowsay'
require 'fortune_gem'
require 'word_wrap'

$config = YAML.load_file('config.yaml')

require_relative 'lib/patches'
require_relative 'lib/utilities'
require_relative 'lib/fun'
require_relative 'lib/admin'
require_relative 'lib/pasta'

# Figlet initialization
$figlet = Figlet::Typesetter.new(Figlet::Font.new("fonts/#{$config['figletFont']}.flf"))

$bot = Discordrb::Commands::CommandBot.new(token: $config['token'],
                                           prefix: $config['prefix'],
                                           advanced_functionality: false,
                                           spaces_allowed: true,
                                           chain_delimiter: '|||',
                                           previous: '---',
                                           ignore_bots: false,
                                           command_doesnt_exist_message: 'zsh: command not found')

$bot.include! Utilities
$bot.include! Fun
$bot.include! Admin
$bot.include! Pasta

$user_type = 'normal'

$bot.command :sudo do |event, *args|
  puts event.author.roles.map { |role| role.id }.include? $config['sudoersRole']
  if event.author.roles.select { |role| role.id == $config['sudoersRole'] }.empty?
    event.channel.send_message("<@#{event.author.id}> is not in the sudoers file. This incident will be reported.")
  else
    run_command = args[0]
    args.slice!(0)
    $user_type = 'sudoer'
    puts run_command
    $bot.execute_command(run_command.to_sym, event, args)
    $user_type = 'normal'
    break # Avoids garbage messages
  end
end

$bot.run
