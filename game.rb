require_relative 'player_types'

class Game
  class NotEnoughNamesError < StandardError; end
  class PlayerMissingError < StandardError; end
  class WrongPhaseError < StandardError; end
  class LynchTargetAlreadySetError < StandardError; end
  class NoLynchTargetSetError < StandardError; end
  class AlreadyVotedError < StandardError; end

  NAMES = [
    "Pete", "John", "Mary", "Mike", "Jane", "Dave", "Maude", "Melanie",
    "Judy", "Mel", "Sylvia", "Pat", "George", "Nick", "Mat", "Monica"
  ]

  INNOCENT_TYPES = [Villager, Healer, Seer]

  attr_reader :phase, :day, :players, :winner

  def initialize(role_counts)
    raise NotEnoughNamesError if role_counts.values.inject(:+) > NAMES.count

    @players = []
    @phase = :lynch
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

  def seer
    select_by_type(Seer).first
  end

  def healer
    select_by_type(Healer).first
  end

  def run
    while !@winner
      puts; puts "--- Day #{@day} begins --- #{stats}"; puts

      run_lynching

      break if @winner

      puts; puts "--- Night #{@day} begins --- #{stats}"; puts

      heal
      see

      werewolf_kill
    end
  end

  def run_lynching
    raise WrongPhaseError if @phase != :lynch

    run_lynching_cycle while phase == :lynch
  end

  def run_lynching_cycle
    raise WrongPhaseError if @phase != :lynch

    voters = players.shuffle

    propose_lynch_target voters.pop

    voters.each { |voter| vote_lynch voter }

    attempt_lynch
  end

  def propose_lynch_target(accuser)
    target = accuser.accuse

    raise LynchTargetAlreadySetError if @lynch_target
    raise PlayerMissingError if !@players.include?(target)

    @vote = { accuser => true }
    @accuser, @lynch_target = accuser, target
  end

  def vote_lynch(voter)
    raise WrongPhaseError if @phase != :lynch
    raise NoLynchTargetSetError if !@lynch_target
    raise AlreadyVotedError if @vote[voter]

    @vote[voter] = voter.vote(@lynch_target)
  end

  def attempt_lynch
    vote_count = @vote.values.select { |value| value }.count

    if vote_count > @players.count.to_f / 2
      remove_player @lynch_target

      puts "#{@lynch_target} has been lynched on #{@accuser}'s proposal"

      update_state
    else
      puts "#{@lynch_target} survived #{@accuser}'s lynch proposal"
    end

    @vote = {}
    @lynch_target, @accuser = nil, nil
  end

  def heal
    return unless healer

    raise WrongPhaseError if @phase != :stealth

    @healing_target = players.sample

    update_state

    puts "#{@healing_target} is being protected by #{healer}"
  end

  def see
    return unless seer

    raise WrongPhaseError if @phase != :stealth

    @seeing_target = seer.seeing_target

    seer.update_knowledge @seeing_target

    update_state

    puts "#{@seeing_target} is being investigated by #{seer}"
    puts "#{seer} currently knows: #{(seer.knowledge - [seer]).join(", ")}"
  end

  def werewolf_kill
    raise WrongPhaseError if @phase != :kill

    target = innocents.sample

    if target == @healing_target
      healer.update_knowledge @healing_target

      puts "#{target} has been saved by #{healer}"
    else
      remove_player target

      puts "#{target} has been killed"
    end

    update_state
  end

  private

  def stats
    werewolves.count.to_s.red + " " +
      villagers.count.to_s.green + " " +
      (seer ? 1 : 0).to_s.blue + " " +
      (healer ? 1 : 0).to_s.yellow
  end

  def remove_player(player)
    @players.delete player

    @players.each(&:sync)
  end

  def select_by_type(type)
    @players.select { |player| player.class == type }
  end

  def update_state
    check_win_conditions if [:lynch, :kill].include? @phase

    if @phase == :lynch
      @phase = (seer || healer) ? :stealth : :kill
    elsif @phase == :stealth &&
        (@seeing_target || !seer) && (@healing_target || !healer)
      @phase = :kill
    elsif @phase == :kill
      @phase = :lynch
      @healing_target, @seeing_target = nil, nil
      @day += 1
    end
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
