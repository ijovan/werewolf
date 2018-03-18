require_relative 'villager'

class Seer < Villager
  attr_reader :knowledge

  def to_s
    "#{super} (seer)".green
  end

  def initialize(id, players)
    @knowledge = [self]

    super(id, players)
  end

  def sync
    @knowledge.select! { |player| @players.alive.include?(player) }
  end

  def see
    candidates = @players.alive - @knowledge

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

    puts "#{self} believes that #{target} is a werewolf and accuses him"

    target
  end

  def vote_decision(target)
    if @players.alive == @players.alive & known_innocents
      puts "#{self} is confused by his findings not adding up " +
        "and disregards them"

      super(target)
    elsif known_innocents.include? target
      if target != self
        puts "#{self} votes to save #{target}, " +
          "whom he believes to be innocent"
      end

      false
    elsif known_werewolves.include?(target)
      puts "#{self} votes to lynch #{target}, " +
        "whom he believes to be a werewolf"

      true
    else
      super(target)
    end
  end

  private

  def known_werewolves
    @knowledge.select { |player| [Werewolf, Miller].include? player.class }
  end

  def known_innocents
    @knowledge.select { |player| ![Werewolf, Miller].include? player.class }
  end
end
