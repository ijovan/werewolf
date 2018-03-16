require 'byebug'
require_relative 'game'

RUNS = 1
ROLE_COUNTS = {
  Werewolf => 2, AlphaWerewolf => 1, Villager => 2, Seer => 1, Hunter => 1,
  Healer => 1, Mason => 2, Scapegoat => 1, RabbleRouser => 1, Miller => 1
}

results = { :innocents => 0, :werewolves => 0, :draw => 0 }

RUNS.times do
  game = Game.new ROLE_COUNTS

  puts "Players: " + game.players.map(&:to_s).join(", ")

  game.run

  results[game.winner] += 1
end

puts
puts "Innocents: #{results[:innocents]}".green + ", " +
  "Werewolves: #{results[:werewolves]}".red + ", " +
  "Draw: #{results[:draw]}".yellow
