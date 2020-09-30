# Allow output from commands to exceed 2000 chars

def split_message_n(msg, n)
  return [] if msg.empty?
  lines = msg.lines

  tri = [*0..(lines.length - 1)].map { |i| lines.combination(i + 1).first }
  joined = tri.map(&:join)

  ideal = joined.max_by { |e| e.length > n ? -1 : e.length }
  ideal_ary = ideal.length > n ? ideal.chars.each_slice(n).map(&:join) : [ideal]

  rest = msg[ideal.length..-1].strip
  return [] unless rest
  ideal_ary + split_message_n(rest, n)
end

module Discordrb::Commands
  # Overwrite of the CommandBot to monkey patch command length
  class CommandBot
    def execute_chain(chain, event)
      t = Thread.new do
        @event_threads << t
        Thread.current[:discordrb_name] = "ct-#{@current_thread += 1}"
        begin
          debug("Parsing command chain #{chain}")
          result = @attributes[:advanced_functionality] ? CommandChain.new(chain, self).execute(event) : simple_execute(chain, event)
          result = event.drain_into(result)

          if event.file
            event.send_file(event.file, caption: result)
          else
            unless result.nil? || result.empty?
              split_message_n(result, 1992).each do |chunk|
                if result && result.start_with?('```') && !chunk.start_with?('```')
                  chunk.prepend "```\n"
                end
                if result && result.end_with?('```') && !chunk.end_with?('```')
                  chunk << "```\n"
                end
                event.respond chunk
              end
            end
          end
        rescue => e
          log_exception(e)
        ensure
          @event_threads.delete(t)
        end
      end
    end
  end
end

