require_relative "player_factory"

class Players
  INNOCENT_TYPES = [
    Villager, Healer, Seer, Mason, Scapegoat, RabbleRouser, Miller, Hunter
  ]

  attr_accessor :innocent_victims
  attr_reader :alive

  def initialize(game, role_counts)
    @alive = []
    @innocent_victims = []
    @game = game
    @alive = PlayerFactory.create(self, role_counts)
  end

  def remove(player)
    alive.delete player
    alive.each(&:sync)

    @game.win(winner)
  end

  def ids
    @alive.map(&:id)
  end

  def werewolf_pack
    ([alpha_werewolf] + werewolves).compact
  end

  def alpha_werewolf
    find_by_type(AlphaWerewolf)
  end

  def werewolves
    select_by_type(Werewolf)
  end

  def innocents
    INNOCENT_TYPES.map { |type| select_by_type type }.inject(:+)
  end

  def villagers
    select_by_type(Villager)
  end

  def masons
    select_by_type(Mason)
  end

  def seers
    select_by_type(Seer)
  end

  def healer
    find_by_type(Healer)
  end

  def hunter
    find_by_type(Hunter)
  end

  def scapegoat
    find_by_type(Scapegoat)
  end

  def rabble_rouser
    find_by_type(RabbleRouser)
  end

  def miller
    find_by_type(Miller)
  end

  def select_by_type(type)
    @alive.select { |player| player.class == type }
  end

  def find_by_type(type)
    select_by_type(type).first
  end

  def stats
    tokens = [
      werewolves.count.to_s.red,
      alpha_werewolf ? "A".red : nil,
      villagers.count.to_s.green,
      masons.any? ? ("Ma".green * masons.count) : nil,
      seers.any? ? ("Se".green * seers.count) : nil,
      healer ? "He".green : nil,
      hunter ? "Hu".green : nil,
      scapegoat ? "Sc".green : nil,
      rabble_rouser ? "R".green : nil,
      miller ? "Mi".green : nil
    ]

    tokens.compact.join(" ")
  end

  def winner
    return Victory::INNOCENT if werewolf_pack.count == 0
    return Victory::WEREWOLF if werewolf_pack.count > innocents.count
    return Victory::DRAW if innocents.count == 1 && hunter
    return Victory::WEREWOLF if werewolf_pack.count == innocents.count
  end
end
