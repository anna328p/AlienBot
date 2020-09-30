# Implements copypasta commands

$pasta = YAML.load_file('pasta.yaml')

module Pasta
  extend Discordrb::Commands::CommandContainer

  command :c do |event, *args|
    if args.size == 0
      return "Available pastas: #{$pasta.keys.map{|k|"`#{k.to_s}`"}.join(' ')}"
    end
    begin
      sed = []
      pasta = args.shift
      args.each { |string| string.split('/').each { |subs| sed.push(subs) } }
      message = $pasta[pasta]
      new_message = $pasta[pasta].dup
      unless sed.empty?
        sed.each_slice(2) do |match, replace|
          begin
            new_message = message.gsub(/#{match}/i, replace || '')
          rescue RegexpError
            event.channel.send_message('Error: Invalid Regex')
            throw :RegexError
          end
        end
      end
      return new_message
    rescue KeyError
      event.channel.send_message('Error: Invalid Pasta')
    end
  end
end
