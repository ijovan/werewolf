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

    if target.class == Miller
      puts "#{self} erroneously believes that #{target} is a werewolf " +
        "and accuses him"
    else
      puts "#{self} correctly believes that #{target} is a werewolf " +
        "and accuses him"
    end

    target
  end

  def vote_decision(target)
    if @game.players == @game.players & known_innocents
      puts "#{self} is confused by his findings not adding up " +
        "and disregards them"

      super(target)
    elsif known_innocents.include? target
      if target != self
        if target.class == AlphaWerewolf
          puts "#{self} votes to save #{target}, " +
            "whom he erroneously believes to be innocent"
        else
          puts "#{self} votes to save #{target}, " +
            "whom he correctly believes to be innocent"
        end
      end

      false
    elsif known_werewolves.include?(target)
      if target.class == Miller
        puts "#{self} votes to lynch #{target}, " +
          "whom he erroneously believes to be a werewolf"
      else
        puts "#{self} votes to lynch #{target}, " +
          "whom he correctly believes to be a werewolf"
      end

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
