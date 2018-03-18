require_relative 'person'

class Villager < Person
  def to_s
    super.green
  end

  protected

  def accusation_target
    candidates = @players.alive - known_innocents

    target = candidates.shuffle.max { |player| suspicion_level player }

    if target && suspicion_level(target) > average_suspicion
      puts "#{self} suspects that #{target} is a werewolf " +
        "and accuses him"

      target
    end
  end

  def vote_decision(target)
    return false if target == self

    if suspicion_level(target) > average_suspicion
      puts "#{self} suspects that #{target} is a werewolf " +
        "and votes for lynching"

      true
    elsif suspicion_level(target) < average_suspicion
      puts "#{self} suspects that #{target} is innocent " +
        "and votes against lynching"

      false
    else
      random_boolean
    end
  end

  def known_innocents
    [self]
  end
end
