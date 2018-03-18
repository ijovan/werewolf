require_relative 'villager'

class Scapegoat < Villager
  def to_s
    "#{super} (scapegoat)".green
  end

  def die(cause = DeathCause::IRRELEVANT)
    if cause == DeathCause::SCAPEGOATING
      puts "No lynching votes have passed - instead, #{self} is killed"

      @players.innocent_victims << self
    end

    super(cause)
  end
end
