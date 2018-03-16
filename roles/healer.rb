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
    average = average_suspicion

    assumed_innocents = @game.players.select do |player|
      player == self || suspicion_level(player) <= average
    end

    @target = assumed_innocents.sample

    puts "#{@target} is being protected by #{self}"

    if @known_innocents.count > 1
      puts "#{self} currenty knows: " +
        (@known_innocents - [self]).join(", ")
    end
  end

  def save
    @known_innocents << @target

    puts "#{@target} has been saved by #{self}"
  end

  protected

  def known_innocents
    @known_innocents
  end

  def vote_decision(target)
    if @known_innocents.include? target
      if target != self
        puts "#{self} votes to save #{target}, " +
          "whom he knows to be innocent"
      end

      false
    else
      super(target)
    end
  end
end
