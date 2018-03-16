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

  def accusation_target
    (@game.players - [self]).sample
  end

  def vote_decision(target)
    return false if target == self

    random_boolean
  end

  def random_boolean
    [true, false].sample
  end
end

