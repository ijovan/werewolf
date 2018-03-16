require_relative 'villager'

class RabbleRouser < Villager
  def to_s
    "#{super} (rabble rouser)".green
  end
end
