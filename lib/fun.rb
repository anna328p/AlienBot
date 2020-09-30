# Implements fluff commands that serve no real use
module Fun
  extend Discordrb::Commands::CommandContainer

  command(:aesthic,
          description: 'Makes a message A E S T H E T I C',
          usage: '[text to convert]',
          min_args: 1) do |_event, *args|
    args.join(' ').to_fullwidth
  end

  command(:step,
          description: 'Show your soles to someone or something',
          usage: '[text]',
          min_args: 1) do |event, *args|
    args.to_a.delete_at(0) if args.include?('on')
    "<@#{event.author.id}> steps on #{args.join(' ')}"
  end

  command(:slap,
          description: 'Hit someone or something',
          usage: '[text]') do |event, *args|
    if  args.map{|s| s.include?('@everyone') || s.include?('@here') }.include?(true)
      return 'nuh uh'
    end
    "<@#{event.author.id}> slaps #{args.join(' ')} around a bit with a large trout"
  end

  command(:figlet,
          description: 'Turns a message into big ASCII art letters',
          usage: '[text]',
          min_args: 1) do |_event, *args|

    input = args.join(' ')

    array = WordWrap.ww(input, 25).split(?\n)

    output = array.map { |l| $figlet[l] }.join(?\n).gsub(?`, ?')

    "```#{output}```"
  end

  command(:cowsay,
          description: 'Wraps a message with an ASCII art cow',
          usage: '[text]',
          min_args: 1) do |_event, *args|
    input_text = WordWrap.ww(args.join(' ').gsub('```', ''), 40)
    rendered_text = Cowsay.say(input_text, 'cow')
    chunked_text = ''
    until rendered_text.empty?
      sliced = rendered_text.slice(0..1990)
      last_index = sliced.length - 1
      last_line = sliced.lines.last
      unless last_line.end_with?('\n') || rendered_text.length == sliced.length
        last_index -= last_line.length
      end
      chunked_text << "```\n" + rendered_text.slice!(0..last_index) + "\n```" \
              + ' ' * last_line.length + "\n"
    end
    chunked_text
  end

  command(:me,
          description: 'Executes a self action',
          usage: '[text]',
          min_args: 1) do |event, *args|
    event.channel.delete_message(event.channel.history(1)[0])
    "<@#{event.user.id}> *#{args.join(' ')}*"
  end

  command(:fortune,
          description: 'Outputs a random fortune / divination / bad joke') do |_event|
    '```' + FortuneGem.give_fortune + '```'
  end
end
