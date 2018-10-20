#!/usr/bin/ruby
require 'set'
require 'yaml'

# The Module for the art relay where one artist draws a thing, and
# when they are done, another random artist is picked
module ArtRelay
  # Loads arists from a YAML file. Default is art_relay.yaml, though
  # you can use whatever filename you like as the first argument
  def load_artists(file = 'art_relay.yaml')
    @artists = YAML.load_file(file)
  end

  # Save the current artists to a file as YAML. Default is
  # art_relay.yaml, though you can override this with the first and
  # only argument
  def save_artists(file = 'art_relay.yaml')
    IO.write(file, @artists.to_yaml)
  end

  # Gets the currently registered artists. Loads from the default file
  # if there is no member in this class, and just creates a new Set
  # object if that isn't a thing either
  def artists
    if @artists.nil?
      begin
        @artists = load_artists
      rescue Errno::ENOENT
        @artists = Set.new
      end
    else
      @artists
    end
  end

  # Reacts to the current artist deleting themselves
  def react_current_artist_deletion
    event.respond <<-RESPONSE
      ...wait, u r the current artist! that means the new one should beeee....'
    RESPONSE

    if artists.empty?
      event.respond 'NOBODY??!?!??!'
      @current_artist = nil
    else
      event.respond 'uhhh...'
      next_artist(event)
    end
  end

  # Registers an artist to be picked from during the rotation
  def bot_art_me(event)
    if artists.add?(event.message.author.id)
      event.respond 'arrite! added now! i will call u wen its drawing time!!'
      save_artists
    else
      event.respond <<-RESPONSE
        you want me to add you again?? okay! okay! i added you again...'
      RESPONSE

      event.respond '...but not really'
    end
  end

  # Removes an artist from the rotation
  def bot_unart_me(event)
    id = event.message.author.id
    if artists.delete?(id)
      event.respond 'okay! buh bye!'
      save_artists

      react_current_artist_deletion if @current_artist == name
    else
      event.respond 'uh... who are u?'
    end
  end

  # Picks a random artist and sets them as the active artist
  def bot_next_artist(event)
    if artists.empty?
      event.respond 'ohnose there are no artist !!'
    else
      @current_artist = artists.to_a.sample
      event.respond [
        "arright! <@#{@current_artist}>! your're up!",
        "your turn, <@#{@current_artist}>!"
      ].sample
    end
  end
end
