require_relative 'villager'

class Seer < Villager
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
    if known_innocents.include? target
      if target != self
        puts "#{self} votes to save #{target}, " +
          "whom he knows to be innocent"
      end

      false
    elsif known_werewolves.include?(target)
      puts "#{self} votes to lynch #{target}, " +
        "whom he knows to be a werewolf"

      true
    else
      super(target)
    end
  end

  def see
    candidates = @game.players - @knowledge

    return if candidates.none?

    target = candidates.sample

    @knowledge << target

    puts "#{target} is being investigated by #{self}"
    puts "#{self} currently knows: #{(@knowledge - [self]).join(", ")}"
  end

  private

  def known_werewolves
    @knowledge.select { |player| player.class == Werewolf }
  end

  def known_innocents
    @knowledge.select { |player| player.class != Werewolf }
  end
end
