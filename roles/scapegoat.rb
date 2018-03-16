require_relative 'villager'

class Scapegoat < Villager
  def to_s
    "#{super} (scapegoat)".green
  end
end
