#!/usr/bin/env ruby

require 'discordrb'
require 'fullwidth'
require 'yaml'
require 'figlet'
require 'cowsay'
require 'fortune_gem'

$config = YAML.load_file('config.yaml')
$pasta = YAML.load_file('pasta.yaml')

require_relative 'lib/patches'
require_relative 'lib/utilities'
require_relative 'lib/fun'
require_relative 'lib/admin'

# Figlet initialization
$figlet = Figlet::Typesetter.new(Figlet::Font.new("fonts/#{$config['figletFont']}.flf"))

$bot = Discordrb::Commands::CommandBot.new(token: $config['token'],
                                           prefix: $config['prefix'],
                                           advanced_functionality: true,
                                           spaces_allowed: true,
                                           chain_delimiter: '|',
                                           previous: '-',
                                           ignore_bots: true,
                                           command_doesnt_exist_message: 'zsh: command not found')

$bot.include! Utilities
$bot.include! Fun
$bot.include! Admin

$user_type = 'normal'

$bot.command :sudo do |event, *args|
  if event.author.roles.select { |role| role.id == $config['sudoersRole'] }.empty?
    event.channel.send_message("<@#{event.author.id}> is not in the sudoers file. This incident will be reported.")
  else
    run_command = args[0]
    args.slice!(0)
    $user_type = 'sudoer'
    $bot.execute_command(run_command.to_sym, event, args)
    $user_type = 'normal'
    break # Avoids garbage messages
  end
end

$bot.command :c do |event, *args|
  if args.size == 0
    return "Available pastas: #{$pasta.keys.map{|k|"`#{k.to_s}`"}.join(' ')}"
  end
  begin
    sed = []
    pasta = args.shift
    args.each { |string| string.split('/').each { |subs| sed.push(subs) } }
    message = $pasta[pasta].dup
    unless sed.empty?
      sed.each_slice(2) do |match, replace|
        begin
          message.gsub!(/#{match}/i, replace || '')
        rescue RegexpError
          event.channel.send_message('Error: Invalid Regex')
          throw :RegexError
        end
      end
    end
    return message
  rescue KeyError
    event.channel.send_message('Error: Invalid Pasta')
  end
end

$bot.run
