require 'colorize'

class Person
  def initialize(id, game)
    @id = id
    @game = game
  end

  def to_s
    @id
  end

  def sync
  end

  def vote(target)
    return false if target == self

    random_boolean
  end

  protected

  def random_boolean
    [true, false].sample
  end
end

