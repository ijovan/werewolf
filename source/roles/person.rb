require 'colorize'

class Person
  class DeathCause
    IRRELEVANT = 0
    WEREWOLVES = 1
    LYNCH = 2
    SCAPEGOATING = 3
  end

  attr_reader :vote_history

  def initialize(id, players)
    @id = id
    @players = players
    @vote_history = { :lynch => [], :no_lynch => [] }
  end

  def to_s
    @id
  end

  def sync
  end

  def die(cause = DeathCause::IRRELEVANT)
    if cause == DeathCause::WEREWOLVES
      healer = @players.healer

      return healer.save if healer && healer.safe?(self)

      @players.innocent_victims << self
    end

    @players.remove self
  end

  def accuse(lynch)
    target = accusation_target

    return unless target

    @vote_history[:lynch] << target

    lynch.accuse(self, target)
  end

  def vote(lynch, target)
    decision = vote_decision(target)

    if decision
      @vote_history[:lynch] << target
    else
      @vote_history[:no_lynch] << target
    end

    lynch.cast_vote(self, decision)
  end

  protected

  def average_suspicion
    suspicion_levels = @players.alive.map do |player|
      suspicion_level(player).to_f
    end

    suspicion_levels.inject(:+) / @players.alive.count
  end

  def suspicion_level(target)
    votes = target.vote_history

    innocents = known_innocents + @players.innocent_victims

    intersection(votes[:lynch], innocents).count -
      intersection(votes[:no_lynch], innocents).count
  end

  def intersection(array_1, array_2)
    array_1.select { |element| array_2.include? element }
  end

  def known_innocents
    []
  end

  def accusation_target
  end

  def vote_decision(target)
  end

  def random_boolean
    [true, false].sample
  end
end
