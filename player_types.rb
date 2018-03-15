require 'colorize'

class Person
  attr_reader :id

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

class Werewolf < Person
  def to_s
    super.red
  end

  def accuse
    (@game.players - @game.werewolves).sample
  end

  def vote(target)
    !@game.werewolves.include?(target)
  end
end

class Villager < Person
  def to_s
    super.green
  end

  def accuse
    (@game.players - [self]).sample
  end
end

class Seer < Person
  attr_reader :knowledge

  def to_s
    super.blue
  end

  def initialize(id, game)
    @knowledge = [self]

    super(id, game)
  end

  def sync
    @knowledge.select! { |player| @game.players.include?(player) }
  end

  def accuse
    candidates =
      if known_werewolves.any?
        known_werewolves
      else
        @game.players - known_innocents
      end

    candidates.sample
  end

  def vote(target)
    return false if known_innocents.include? target

    known_werewolves.include?(target) || super(target)
  end

  def seeing_target
    candidates = @game.players - @knowledge

    candidates.any? ? candidates.sample : self
  end

  def update_knowledge(player)
    @knowledge << player
  end

  private

  def known_werewolves
    @knowledge.select { |player| player.class == Werewolf }
  end

  def known_innocents
    @knowledge.select { |player| player.class != Werewolf }
  end
end

class Healer < Person
  def initialize(id, game)
    @known_innocents = [id]

    super(id, game)
  end

  def to_s
    super.yellow
  end

  def sync
    @known_innocents.select! { |player| @game.players.include? player }
  end

  def accuse
    (@game.players - @known_innocents).sample
  end

  def vote(target)
    @known_innocents.include?(target) ? false : random_boolean
  end

  def update_knowledge(player)
    @known_innocents << player
  end
end
