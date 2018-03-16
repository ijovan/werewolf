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

  def see
    candidates = @game.players - @knowledge

    return if candidates.none?

    target = candidates.shuffle.max { |player| suspicion_level(player) }

    if suspicion_level(target) > average_suspicion
      puts "#{self} suspects #{target} of being a werewolf and " +
        "investigates him"
    else
      puts "#{target} is being investigated by #{self}"
    end

    @knowledge << target

    puts "#{self} currently knows: #{(@knowledge - [self]).join(", ")}"
  end

  protected

  def accusation_target
    return super if known_werewolves.none?

    target = known_werewolves.sample

    "#{self} knows that #{target} is a werewolf and accuses him"

    target
  end

  def vote_decision(target)
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

  private

  def known_werewolves
    @knowledge.select { |player| player.class == Werewolf }
  end

  def known_innocents
    @knowledge.select { |player| player.class != Werewolf }
  end
end
