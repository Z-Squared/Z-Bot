#!/usr/bin/ruby
require 'open-uri'
require 'nokogiri'
require 'differ'

# The idea behind this module is to watch a section of a page on
# someone's behalf, and @ them when it changes
module WatchPage
  # Watches a page you specify at the current
  def bot_watch(event, url, css)
    event.respond "okay! i will watch it.."

    # If a thread already exists
    unless @thread.nil?
      sleep rand(3)
      event.respond "but i only watch can 1 thin so i stop looking at #{@url} now.!"

      if @id != event.message.author.id then
        sleep rand(3)
        event.respond "sorry <@#{@id}>"
      end

      @thread.exit
    end

    # New state now that we don't care about the last task (if there even was one)
    @url = url
    @css = css
    @id = event.message.author.id

    # The thread creation
    begin
      @thread = Thread.new do
        current = Nokogiri::parse(open @url).css(@css).inner_text

        loop do
          sleep 60 * 10
          checked = Nokogiri::parse(open @url).css(@css).inner_text

          if checked != current then
            event.respond "hay! haaaay! <@#{@id}>! ur page changed at #{@url}"
            event.respond "it was diff uhhh liek..."
            event.respond Differ.diff_by_line(checked, current).to_s[/\{[^}]+\}/][1...-1].gsub(/\s{2,}/, '')
            current = checked
          end
        end
      end
    rescue
      event.respond "aaaaaahhhhhh!!!! i run into errer wen i tried to watch #{@url}"
    end
  end

  # Stops watching a page if there is one
  def bot_stop_watching(event)
    if @thread.nil? then
      event.respond "but i not watch thing rigth now???"
    else
      event.respond "i stop watc #{@url} at #{@css}"
      @thread.exit
    end
  end
end
