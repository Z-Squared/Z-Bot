#!/usr/bin/ruby
require 'set'

# The Module for the art relay where one artist draws a thing, and
# when they are done, another random artist is picked
module ArtRelay
  def artists
    @artists = @artists || Set.new
  end

  # Registers an artist to be picked from during the rotation
  def bot_art_me(event)
    if artists.add?(event.message.author.id) then
      event.respond "arrite! added now! i will call u wen its drawing time!!"
    else
      event.respond "you want me to add you again?? okay! okay! i added you again..."
      event.respond "...but not really"
    end
  end

  # Removes an artist from the rotation
  def bot_unart_me(event)
    id = event.message.author.id
    if artists.delete?(id) then
      event.respond "okay! buh bye!"

      if @current_artist == name then
        event.respond "...wait, u r the current artist! that means the new one should beeee...."
        if artists.empty? then
          event.respond "NOBODY??!?!??!"
          @current_artist = nil
        else
          sleep rand(3)
          event.respond "uhhh..."
          sleep rand(3)
          next_artist(event)
        end
      end
    else
      event.respond "uh... who are u?"
    end
  end

  # Picks a random artist and sets them as the active artist
  def bot_next_artist(event)
    if artists.empty? then
      event.respond "ohnose there are no artist !!"
    else
      @current_artist = artists.to_a.sample
      event.respond [
        "arright! <@#{@current_artist}>! your're up!",
        "your turn, <@#{@current_artist}>!"
      ].sample
    end
  end
end
