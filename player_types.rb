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

class Mason < Person
  def to_s
    "#{super} (mason)".green
  end

  def accuse
    (@game.players - @game.masons).sample
  end

  def vote(target)
    @game.masons.include?(target) ? false : random_boolean
  end
end

class Seer < Person
  attr_reader :knowledge

  def to_s
    "#{super} (seer)".green
  end

  def initialize(id, game)
    @knowledge = [self]

    super(id, game)
  end

  def sync
    @knowledge.select! { |player| @game.players.include?(player) }
  end

  def accuse
    if known_werewolves.any?
      known_werewolves.sample
    else
      (@game.players - known_innocents).sample
    end
  end

  def vote(target)
    return false if known_innocents.include? target

    known_werewolves.include?(target) || super(target)
  end

  def see
    candidates = @game.players - @knowledge

    target = candidates.any? ? candidates.sample : self

    @knowledge << target

    puts "#{target} is being investigated by #{self}"
    puts "#{self} currently knows: #{(knowledge - [self]).join(", ")}"
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
  attr_reader :target

  def initialize(id, game)
    @known_innocents = [self]

    super(id, game)
  end

  def to_s
    "#{super} (healer)".green
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

  def heal
    @target = @game.players.sample

    puts "#{@target} is being protected by #{self}"
  end

  def save
    @known_innocents << @target

    puts "#{@target} has been saved by #{self}"
  end
end