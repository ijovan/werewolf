require 'byebug'
require_relative 'source/game'

RUNS = 1
ROLE_COUNTS = {
  Werewolf => 2, AlphaWerewolf => 1, Villager => 2, Seer => 1, Hunter => 1,
  Healer => 1, Mason => 2, Scapegoat => 1, RabbleRouser => 1, Miller => 1
}

results = {
  Victory::INNOCENT => 0,
  Victory::WEREWOLF => 0,
  Victory::DRAW => 0
}

RUNS.times do
  game = Game.new ROLE_COUNTS

  game.run

  results[game.winner] += 1
end

puts
puts "Innocents: #{results[Victory::INNOCENT]}".green + ", " +
  "Werewolves: #{results[Victory::WEREWOLF]}".red + ", " +
  "Draw: #{results[Victory::DRAW]}".yellow
