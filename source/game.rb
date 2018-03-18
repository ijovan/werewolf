require_relative "players"
require_relative "lynch"
require_relative "victory"

class Game
  attr_reader :players, :winner

  def initialize(role_counts)
    @day = 1
    @players = Players.new self, role_counts

    puts "Players: " + @players.alive.join(", ")
  end

  def run
    while !@winner
      run_day

      break if @winner

      run_night

      @day += 1
    end

    Victory.proclaim_winner(@winner)
  end

  def win(winner)
    @winner = winner
  end

  private

  def run_day
    stats "Day"

    Lynch.new(@players).run

    if @players.rabble_rouser && !@winner
      @players.rabble_rouser.entice

      Lynch.new(@players).run
    end
  end

  def run_night
    stats "Night"

    @players.healer.heal if @players.healer
    @players.seers.each(&:see)
    @players.werewolf_pack.first.kill
  end

  def stats(phase)
    puts
    puts "--- #{phase} #{@day} begins --- #{@players.stats}"
    puts
  end
end
