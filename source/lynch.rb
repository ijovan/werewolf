class Lynch
  LYNCH_LIMIT = 2

  def self.run(players)
    self.new(players).run
  end

  def initialize(players)
    @players = players
    @alive = players.alive
  end

  def run
    previous_count = @alive.count

    LYNCH_LIMIT.times do
      run_vote

      return if @alive.count < previous_count
    end

    if @players.scapegoat
      @players.scapegoat.die(Person::DeathCause::SCAPEGOATING)
    else
      puts "No lyching happened in this round"
    end
  end

  def accuse(accuser, target)
    @lynch_target = target
    @vote = { accuser => true }
  end

  def cast_vote(voter, vote)
    @vote[voter] ||= vote
  end

  private

  def run_vote
    @alive.shuffle.pop.accuse(self) while !@lynch_target

    (@alive.shuffle - [@vote.keys.first]).each do |voter|
      voter.vote self, @lynch_target
    end

    process
  end

  def process
    counts = vote_counts
    text = "#{counts[true]} for and #{counts[false]} against"

    if counts[true] <= counts[false]
      puts "#{@lynch_target} survived the lynch proposal with #{text}"

      @lynch_target, @votes = nil, {}

      return
    end

    puts "#{@lynch_target} has been lynched with #{text}"

    @lynch_target.die
  end

  def vote_counts
    groups = @vote.values.group_by { |value| value }

    groups.map { |key, value| [key, value.count] }.to_h
  end
end
