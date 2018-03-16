require_relative 'villager'

class Mason < Villager
  def to_s
    "#{super} (mason)".green
  end

  protected

  def accusation_target
    (@game.players - @game.masons).sample
  end

  def vote_decision(target)
    if @game.masons.include? target
      if target != self
        puts "#{self} votes to save #{target}, a fellow mason"
      end

      false
    else
      random_boolean
    end
  end
end
