require_relative 'werewolf'

class AlphaWerewolf < Werewolf
  def to_s
    "#{super} (alpha werewolf)".red
  end
end
