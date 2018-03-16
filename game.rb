require_relative 'player_types'

class Game
  class NotEnoughNamesError < StandardError; end

  NAMES = [
    "Pete", "John", "Mary", "Mike", "Jane", "Dave", "Maude", "Melanie",
    "Judy", "Mel", "Sylvia", "Pat", "George", "Nick", "Mat", "Monica"
  ]

  INNOCENT_TYPES = [Villager, Healer, Seer, Mason]

  attr_reader :players, :winner

  def initialize(role_counts)
    if role_counts.values.inject(:+) > NAMES.count
      raise NotEnoughNamesError
    end

    @players = []
    @day = 1

    names = NAMES.shuffle

    role_counts.map do |role, count|
      count.times { @players << role.new(names.pop, self) }
    end
  end

  def ids
    @players.map(&:id)
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
  end

  def run_night
    puts; puts "--- Night #{@day} begins --- #{stats}"; puts

    healer.heal if healer
    seer.see if seer

    werewolf_kill
  end

  def run_lynching
    count = @players.count

    run_lynching_cycle while @players.count == count
  end

  def run_lynching_cycle
    voters = players.shuffle

    propose_lynch_target voters.pop

    voters.each { |voter| vote_lynch voter }

    attempt_lynch
  end

  def propose_lynch_target(accuser)
    target = accuser.accuse

    @vote = { accuser => true }
    @accuser, @lynch_target = accuser, target
  end

  def vote_lynch(voter)
    @vote[voter] = voter.vote(@lynch_target)
  end

  def attempt_lynch
    vote_count = @vote.values.select { |value| value }.count

    if vote_count > @players.count.to_f / 2
      puts "#{@lynch_target} has been lynched on #{@accuser}'s proposal"

      remove_player @lynch_target
    else
      puts "#{@lynch_target} survived #{@accuser}'s lynch proposal"
    end

    @vote = {}
    @lynch_target, @accuser = nil, nil
  end

  def werewolf_kill
    target = innocents.sample

    if healer && target == healer.target
      healer.save
    else
      puts "#{target} has been killed"

      remove_player target
    end
  end

  def stats
    tokens = [
      werewolves.count.to_s.red, villagers.count.to_s.green,
      seer ? "S".green : nil, healer ? "H".green : nil,
      masons.any? ? "#{masons.count}M".green : nil
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
    if werewolves.count == 0
      innocents_win
    elsif werewolves.count >= innocents.count
      werewolves_win
    end
  end

  def innocents_win
    puts; puts "Innocents win".green

    @winner = :innocents
  end

  def werewolves_win
    puts; puts "Werewolves win".red

    @winner = :werewolves
  end
end
