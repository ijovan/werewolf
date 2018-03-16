require_relative 'person'

class Werewolf < Person
  def to_s
    super.red
  end

  protected

  def accusation_target
    (@game.players - @game.werewolves).sample
  end

  def vote_decision(target)
    if @game.werewolves.include? target
      if target != self
        puts "#{self} votes to save #{target}, a fellow werewolf"
      end

      false
    else
      true
    end
  end
end

