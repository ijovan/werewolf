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
        "#{target}, whom he suspects of being a werewolf"

      target
    else
      puts "#{self} fires off a shot before being killed " +
        "but doesn't hit anyone"

      nil
    end
  end
end
