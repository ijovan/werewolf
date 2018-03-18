require_relative 'villager'

class Mason < Villager
  def to_s
    "#{super} (mason)".green
  end

  protected

  def known_innocents
    @players.masons
  end

  def vote_decision(target)
    if @players.masons.include? target
      if target != self
        puts "#{self} votes to save #{target}, a fellow mason"
      end

      false
    else
      super(target)
    end
  end
end
