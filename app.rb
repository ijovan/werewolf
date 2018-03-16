require 'byebug'
require_relative 'game'

RUNS = 1
ROLES = {
  Werewolf => 2, Villager => 6, Seer => 1, Healer => 1, Mason => 2
}

results = {:innocents => 0, :werewolves => 0}

RUNS.times do
  game = Game.new ROLES

  puts "Players: " + game.players.map(&:to_s).join(", ")

  game.run

  results[game.winner] += 1
end

puts
puts "Innocents: #{results[:innocents]}".green + ", " +
  "Werewolves: #{results[:werewolves]}".red
