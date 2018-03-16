require_relative 'villager'

class Miller < Villager
  def to_s
    "#{super} (miller)".green
  end
end
