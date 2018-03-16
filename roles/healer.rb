require_relative 'villager'

class Healer < Villager
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

  def heal
    @target = @game.players.sample

    puts "#{@target} is being protected by #{self}"
  end

  def save
    @known_innocents << @target

    puts "#{@target} has been saved by #{self}"
  end

  protected

  def accusation_target
    (@game.players - @known_innocents).sample
  end

  def vote_decision(target)
    if @known_innocents.include? target
      if target != self
        puts "#{self} votes to save #{target}, " +
          "whom he knows to be innocent"
      end

      false
    else
      random_boolean
    end
  end
end
