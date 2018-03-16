ROLES = [
  "werewolf", "villager", "healer", "seer",
  "mason", "scapegoat", "rabble_rouser", "alpha_werewolf"
]
ROLES.each { |role| require_relative "roles/#{role}" }

class Game
  class NotEnoughNamesError < StandardError; end

  NAMES = [
    "Pete", "John", "Mary", "Mike", "Jane", "Dave", "Maude", "Melanie",
    "Judy", "Mel", "Sylvia", "Pat", "George", "Nick", "Mat", "Monica"
  ]

  INNOCENT_TYPES = [Villager, Healer, Seer, Mason, Scapegoat, RabbleRouser]

  LYNCH_LIMIT = 3

  attr_reader :players, :winner, :werewolf_victims

  def initialize(role_counts)
    if role_counts.values.inject(:+) > NAMES.count
      raise NotEnoughNamesError
    end

    @players = []
    @werewolf_victims = []
    @day = 1

    names = NAMES.shuffle

    role_counts.map do |role, count|
      count.times { @players << role.new(names.pop, self) }
    end
  end

  def ids
    @players.map(&:id)
  end

  def werewolf_pack
    ([alpha_werewolf] + werewolves).compact
  end

  def alpha_werewolf
    select_by_type(AlphaWerewolf).first
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

  def seer
    select_by_type(Seer).first
  end

  def healer
    select_by_type(Healer).first
  end

  def scapegoat
    select_by_type(Scapegoat).first
  end

  def rabble_rouser
    select_by_type(RabbleRouser).first
  end

  def run
    while !@winner
      run_day

      break if @winner

      run_night

      @day += 1
    end
  end

  private

  def run_day
    puts; puts "--- Day #{@day} begins --- #{stats}"; puts

    run_lynching

    if rabble_rouser
      puts; puts "#{rabble_rouser} entices the crowd into another lynch"

      run_lynching
    end
  end

  def run_night
    puts; puts "--- Night #{@day} begins --- #{stats}"; puts

    healer.heal if healer
    seer.see if seer

    werewolf_kill
  end

  def run_lynching
    count = @players.count

    LYNCH_LIMIT.times do
      run_lynching_cycle

      return if @players.count < count
    end

    if scapegoat
      puts "No lynching votes have passed - " +
        "instead, #{scapegoat} is killed"

      @werewolf_victims << scapegoat

      remove_player scapegoat
    else
      puts "No lyching happened today"
    end
  end

  def run_lynching_cycle
    propose_lynch_target

    players.shuffle.each { |voter| vote_lynch voter }

    attempt_lynch
  end

  def propose_lynch_target
    accuser = players.shuffle.pop

    @lynch_target = accuser.accuse

    @vote = { accuser => true }
  end

  def vote_lynch(voter)
    @vote[voter] ||= voter.vote(@lynch_target)
  end

  def attempt_lynch
    votes_for = @vote.values.select { |value| value }.count
    votes_against = @players.count - votes_for

    if votes_for > votes_against
      puts "#{@lynch_target} has been lynched " +
        "with #{votes_for} for and #{votes_against} against"

      remove_player @lynch_target
    else
      puts "#{@lynch_target} survived the lynch proposal " +
        "with #{votes_for} for and #{votes_against} against"
    end

    @vote = {}
    @lynch_target = nil
  end

  def werewolf_kill
    target = werewolf_pack.first.kill_target

    if healer && target == healer.target
      healer.save
    else
      puts "#{target} has been killed by the werewolves"

      @werewolf_victims << target

      remove_player target
    end
  end

  def stats
    tokens = [
      werewolves.count.to_s.red, alpha_werewolf ? "A".red : nil,
      villagers.count.to_s.green, seer ? "Se".green : nil,
      healer ? "H".green : nil,
      masons.any? ? ("M".green * masons.count) : nil,
      scapegoat ? "Sc".green : nil, rabble_rouser ? "R".green : nil
    ]

    tokens.compact.join(" ")
  end

  def remove_player(player)
    @players.delete player
    @players.each(&:sync)

    check_win_conditions
  end

  def select_by_type(type)
    @players.select { |player| player.class == type }
  end

  def check_win_conditions
    if werewolf_pack.count == 0
      innocents_win
    elsif werewolf_pack.count >= innocents.count
      werewolves_win
    end
  end

  def innocents_win
    puts
    puts "There are no more werewolves left"
    puts "Innocents win".green

    @winner = :innocents
  end

  def werewolves_win
    puts
    puts "Werewolves come out and slaughter the remaining villagers"
    "Werewolves win".red

    @winner = :werewolves
  end
end
