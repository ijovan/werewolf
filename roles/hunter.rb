require_relative 'villager'

class Hunter < Villager
  def to_s
    "#{super} (hunter)".green
  end

  def shoot
    candidates = @game.players - [self]

    target = candidates.shuffle.max { |player| suspicion_level player }

    if suspicion_level(target) > average_suspicion
      puts "#{self} fires off a shot before being killed - he kills " +
        "#{target}, whom he believed to be a werewolf"
    end

    target
  end
end
