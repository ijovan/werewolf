require 'colorize'

class Person
  attr_reader :vote_history

  def initialize(id, game)
    @id = id
    @game = game
    @vote_history = { :lynch => [], :no_lynch => [] }
  end

  def to_s
    @id
  end

  def sync
  end

  def accuse
    target = accusation_target

    @vote_history[:lynch] << target

    target
  end

  def vote(target)
    decision = vote_decision(target)

    if decision
      @vote_history[:lynch] << target
    else
      @vote_history[:no_lynch] << target
    end

    decision
  end

  protected

  def average_suspicion
    players = @game.players

    suspicion_levels = players.map { |player| suspicion_level(player).to_f }

    suspicion_levels.inject(:+) / players.count
  end

  def suspicion_level(target)
    votes = target.vote_history

    innocents = known_innocents + @game.innocent_victims

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
