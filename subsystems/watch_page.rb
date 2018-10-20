#!/usr/bin/ruby
require 'open-uri'
require 'nokogiri'
require 'differ'

# The idea behind this module is to watch a section of a page on
# someone's behalf, and @ them when it changes
module WatchPage
  # Quits the thread currently running in this module
  def quit_thread(event)
    event.respond <<-RESPONSE
      but i only watch can 1 thin so i stop looking at #{@url} now.!
    RESPONSE

    event.respond "sorry <@#{@id}>" if @id != event.message.author.id
    @thread.exit
  end

  # Watches a page you specify at the current
  def bot_watch(event, url, css)
    event.respond 'okay! i will watch it..'
    @url = url
    @css = css
    @id = event.message.author.id

    quit_thread(event) unless @thread.nil?
    make_watcher(event)
  end

  # Gets a text version of the diff between two strings
  def diffed(old, new)
    differ = Differ.diff_by_line(new, old)
    differ.to_s[/\{[^}]+\}/][1...-1].gsub(/\s{2,}/, '')
  end

  # Checks the attached @url at the attached @css, and compares it to
  # what was passed in.
  #
  # If there's a change, the bot yells about it
  def check_page(current)
    checked = Nokogiri.parse(URI.parse(@url).open).css(@css).inner_text

    if checked != current
      event.respond "hay! haaaay! <@#{@id}>! ur page changed at #{@url}"
      event.respond 'it was diff uhhh liek...'
      event.respond diffed(checked, current)
    end

    checked
  end

  # Makes a watcher and assigns it to @thread
  def make_watcher(event)
    # The thread creation
    @thread = Thread.new do
      current = Nokogiri.parse(URI.parse(@url).open).css(@css).inner_text

      loop do
        sleep 60 * 10
        current = check_page(current, checked)
      end
    end
  rescue e
    event.respond <<-RESPONSE
      aaaaaahhhhhh!!!! i run into errer wen i tried to watch #{@url}
    RESPONSE
  end

  # Stops watching a page if there is one
  def bot_stop_watching(event)
    if @thread.nil?
      event.respond 'but i not watch thing rigth now???'
    else
      event.respond "i stop watc #{@url} at #{@css}"
      @thread.exit
    end
  end
end
