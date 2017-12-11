#!/usr/bin/ruby
# coding: utf-8

# Libraries!
require 'discordrb'
require 'yaml'

# My things!
require_relative 'lib/text_utils'
require_relative 'subsystems/admin'
require_relative 'subsystems/art_relay'
require_relative 'subsystems/teh_penguin'

# Configuration
CONFIG = YAML.load_file("config.yaml")

# Hardcoded IDs, yay!
# Some Channels
CHANNELS = {
  :test => 388891500521586699
}

# Some users
USERS = {
  :archenoth => 270383242539040768
}

# Some servers
SERVERS = {
  :z_squared => 270384464104914944
}

bot = Discordrb::Bot.new(
  token: CONFIG[:token],
  client_id: CONFIG[:client_id]
)

# The main dispatcher for bang commands
#
# By default, "!Things like this" will be converted into a command
# called "bot_things_like_this", and we will try to call that function
# on this class or any of the included mixins with the event as the
# argument
#
# If that doesn't exist, we will instead try to call "bot_things" in
# all of these places with the first argument being the event, and the
# rest of the arguments being "like" and "this"
class Botman
  # Libraries
  include TextUtils

  # Subsystems
  include AdminCommands
  include ArtRelay
  include TehPenguin

  def initialize(bot)
    @bot = bot

    bot.message(begins_with: "!") do |event|
      command = event.message.text[1..-1].split(" ")
      dispatch(command, event)
    end
  end

  # Given an array of strings, first attempts to call the result of
  # joining all of these strings with underscores, downcasing them,
  # and prefixing it with "bot_" as a function. (So ["Terminate" "It"]
  # would attempt to call a function called "bot_terminate_it" in this
  # class with the argument being the message event)
  #
  # If that doesn't exist, it then tries to do the same thing with the
  # first word of the command array, and pass the remaining array
  # values as arguments after the event, so ["Terminate" "It"] would
  # attempt to call "bot_terminate" in this class with the first
  # argument, again being the message event, but the second argument
  # would be "It"
  #
  # And finally, if that doesn't work and the message author is our
  # lovely hardcoded person-who-definitely-isn't-me-or-anything, it
  # passes the two arguments passed into this function to
  # admin_dispatch instead
  #
  # If no methods match and the caller is not lololo-not-me, this
  # function does nothing more.
  def dispatch(command, event)
    whole_command = 'bot_' + command.join("_").downcase
    first_word_command = 'bot_' + command.first.downcase

    if(respond_to?(whole_command))
      send(whole_command, event)
    elsif(respond_to?(first_word_command))
      send(first_word_command, event, *command[1..-1])
    elsif(event.message.author.id == USERS[:archenoth])
      admin_dispatch(command, event)
    end
  end

  # The same thing as dispatch, except more adminy
  #
  # Instead of prefixing with "bot_", this dispatcher prefixes with
  # "admin_"
  #
  # If no methods match, this function does nothing.
  def admin_dispatch(command, event)
    admin_command = 'admin_' + command.join("_").downcase
    admin_first_word_command = 'admin_' + command.first.downcase

    if(respond_to?(admin_command))
      send(admin_command, event)
    elsif(respond_to?(admin_first_word_command))
      send(admin_first_word_command, event, *command[1..-1])
    end
  end

  # Runs the bot! (Not done immediately so you can add other handlers
  # to it first.
  #
  # @arg async <Boolean>: true if you want this call to be
  # non-blocking, false for blocking. Defaults to false
  def run(async=false)
    @bot.run(async)
  end
end

botman = Botman.new(bot)

#### THE FUN ZONE loLOLOl ####

# Random and arbitrary commands
bot.message(content: "Nico") do |event|
  event.respond "Nico niii#{'i' * rand(20)}!"
end

bot.message(contains: 'I am bot') do |event|
  event.respond "Hahahaha! Silly dumb robot!"
end

bot.message(content: "oh hi bot") do |event|
  event.respond "oh hey #{event.message.author.name.downcase} what's up"
end

# And finally, run the bot!
botman.run
