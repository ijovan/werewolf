require_relative 'person'

class Werewolf < Person
  def to_s
    super.red
  end

  def kill
    target = known_innocents.shuffle.min do |player|
      suspicion_level(player)
    end

    if suspicion_level(target) < average_suspicion
      puts "Werewolves target #{target}, suspecting him of being " +
        "a special innocent"
    end

    target.die(DeathCause::WEREWOLVES)

    return if @players.alive.include? target

    puts "#{target} has been killed by the werewolves"
  end

  protected

  def known_innocents
    @players.innocents
  end

  def accusation_target
    candidates = @players.alive - @players.werewolf_pack

    target = candidates.shuffle.min { |player| suspicion_level player }

    if suspicion_level(target) < average_suspicion
      puts "#{self} suspects that #{target} is a special innocent " +
        "and accuses him"
    else
      puts "#{self} has accused #{target}"
    end

    target
  end

  def vote_decision(target)
    if @players.werewolf_pack.include? target
      if target != self
        puts "#{self} votes to save #{target}, a fellow werewolf"
      end

      return false
    end

    true
  end
end

