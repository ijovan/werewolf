require_relative 'person'

class Villager < Person
  def to_s
    super.green
  end

  def accuse
    (@game.players - [self]).sample
  end
end
