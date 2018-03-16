require_relative 'person'

class Werewolf < Person
  def to_s
    super.red
  end

  def kill_target
    target = known_innocents.min { |player| suspicion_level(player) }

    if suspicion_level(target) < average_suspicion
      puts "Werewolves target #{target}, suspecting him of being " +
        "a special innocent"
    end

    target
  end

  protected

  def known_innocents
    @game.innocents
  end

  def accusation_target
    candidates = @game.players - @game.werewolves

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
    if @game.werewolves.include? target
      if target != self
        puts "#{self} votes to save #{target}, a fellow werewolf"
      end

      false
    else
      true
    end
  end
end

