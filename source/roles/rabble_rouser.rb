require_relative 'villager'

class RabbleRouser < Villager
  def to_s
    "#{super} (rabble rouser)".green
  end

  def entice
    puts
    puts "#{@players.rabble_rouser} entices the crowd into another lynch"
  end
end
