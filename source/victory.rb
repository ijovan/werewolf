class Victory
  DRAW = 0
  INNOCENT = 1
  WEREWOLF = 2

  def self.proclaim_winner(winner)
    case winner
    when DRAW then draw
    when INNOCENT then innocents_win
    when WEREWOLF then werewolves_win
    end
  end

  private

  def self.draw
    puts
    puts "The remaining werewolf and hunter kill each other"
    puts "It's a draw".yellow
  end

  def self.innocents_win
    puts
    puts "There are no more werewolves left"
    puts "Innocents win".green
  end

  def self.werewolves_win
    puts
    puts "Werewolves come out and slaughter the remaining villagers"
    puts "Werewolves win".red
  end
end
