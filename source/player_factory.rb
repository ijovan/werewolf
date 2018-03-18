ROLES = [
  "werewolf", "villager", "healer", "seer", "miller", "hunter",
  "mason", "scapegoat", "rabble_rouser", "alpha_werewolf"
]
ROLES.each { |role| require_relative "roles/#{role}" }

class PlayerFactory
  class NotEnoughNamesError < StandardError; end

  NAMES = [
    "Pete", "John", "Mary", "Mike", "Jane", "Dave", "Maude", "Melanie",
    "Judy", "Mel", "Sylvia", "Pat", "George", "Nick", "Mat", "Monica"
  ]

  def self.create(player_collection, role_counts)
    if role_counts.values.inject(:+) > NAMES.count
      raise NotEnoughNamesError
    end

    names = NAMES.shuffle
    players = []

    role_counts.map do |role, count|
      count.times do
        players << role.new(names.pop, player_collection)
      end
    end

    players
  end
end
