#!/usr/bin/ruby

# A module for dumb random things and tests and
# experiments...basically things that don't belong anywhere else.
module TehPenguin
  # Creates a simple thread that starts after the number of seconds passed in
  def timer(time)
    Thread.new do
      sleep time
      yield
    end
  end

  ## Keeps track of a minute
  def bot_minute(event)
    if @minutes
      event.respond 'i already count. but i cant do two count,,'
    else
      @minutes = true
      event.respond 'okaaay!! one minute i reming u!'

      timer(60) do
        event.respond 'minutee up!'
        @minutes = false
      end
    end
  end

  # Dice!
  def bot_dice(event, num = '6')
    event.respond "rolled a #{rand(num.to_i) + 1}!"
  end

  # Russian Roulette. 1/6 chance to kick
  def bot_rr(event)
    if rand(6).zero?
      event.respond '**BANG!**'
      event.server.kick(event.author)
    else
      event.respond '*click*'
    end
  end

  # Pretend to reboot and unset @glitched
  def reboot(event)
    @rebooting = true
    event.respond 'Rebooting...'
    sleep 10
    event.respond 'Walcom to BOT.EXE dot rb, now loading....'
    sleep 10
    event.respond 'ah, ahem... hi, im back'
    @glitched = false
    @rebooting = false
  end

  # Pretending to fix things...
  def bot_reboot(event)
    if @glitched
      reboot(event)
    else
      event.respond [
        'i no need dis',
        "im afraid i cant let you do that #{event.message.author.name}"
      ].sample
    end
  end

  # I can hardly Mileve it!
  def bot_mileve(event)
    event.respond "Mileve grabs #{event.message.author.name} from an " \
                  'absurdly far distance bringing them into a strong hug. ' \
                  'She proceeds by spinning at traumatizing speeds before ' \
                  "releasing the embrace of #{event.message.author.name} " \
                  'resulting in their flying through the sky!'
  end
end
