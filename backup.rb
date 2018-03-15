require 'byebug'
require 'colorize'

class Person
  attr_reader :id

  def initialize(id, village)
    @id = id
    @village = village
  end

  def sync
  end

  def vote(target)
    return false if target == @id

    random_boolean
  end

  protected

  def random_boolean
    [true, false].sample
  end
end

class Werewolf < Person
  def accuse
    (@village.ids - @village.werewolves.map(&:id)).sample
  end

  def vote(target)
    !@village.werewolves.map(&:id).include?(target)
  end
end

class Villager < Person
  def accuse
    (@village.ids - [@id]).sample
  end
end

class Seer < Person
  attr_reader :knowledge

  def initialize(id, village)
    @knowledge = { :seer => id }

    super(id, village)
  end

  def sync
    @knowledge.select! { |id, _| @village.ids.include?(id) }
  end

  def accuse
    groups = known_groups

    candidates =
      if groups[:werewolf].to_a.any?
        groups[:werewolf].to_a
      else
        @village.ids - groups[:villager].to_a -
          groups[:healer].to_a - [@id]
      end

    candidates.sample
  end

  def vote(target)
    groups = known_groups

    groups[:werewolf].to_a.include?(target) ||
      !@knowledge.keys.include?(target) ||
      super(target)
  end

  def seeing_target
    candidates = @village.ids - @knowledge.keys

    candidates.any? ? candidates.sample : id
  end

  def update_knowledge(id, type)
    @knowledge[id] = type
  end

  private

  def known_groups
    @knowledge
      .group_by { |_, value| value }
      .map { |key, value| [key, value.to_h.keys] }
      .to_h
  end
end

class Healer < Person
  def initialize(id, village)
    @known_innocents = [id]

    super(id, village)
  end

  def sync
    @known_innocents.select! { |id| @village.ids.include? id }
  end

  def accuse
    (@village.ids - @known_innocents).sample
  end

  def vote(target)
    @known_innocents.include?(target) ? false : random_boolean
  end

  def update_knowledge(id)
    @known_innocents << id
  end
end

class Village
  attr_reader :players

  def initialize()
    @players = []
  end

  def create_player(type, id)
    @players << type.new(id, self)
  end

  def sync(player_list)
    @players.select! { |player| player_list.include? player.id }

    @players.each(&:sync)
  end

  def ids
    @players.map(&:id)
  end

  def healer
    select_by_type(Healer).first
  end

  def seer
    select_by_type(Seer).first
  end

  def werewolves
    select_by_type(Werewolf)
  end

  def count
    @players
      .group_by { |player| player.class }
      .map { |key, value| [key, value.count] }
      .to_h
  end

  def player_by_id(id)
    @players.find { |player| player.id == id }
  end

  private

  def select_by_type(type)
    @players.select { |player| player.class == type }
  end
end

class Game
  attr_reader :phase, :players, :proposed_for_lynch, :winner

  def initialize(num_werewolves, num_villagers)
    @roles = [:werewolf] * num_werewolves + [:healer, :seer] +
      [:villager] * num_villagers
    @roles.shuffle!

    @players = {}
  end

  def register_player(address)
    raise if @roles.empty? || @players.include?(address)

    role = @roles.pop

    @players[address] = role

    @phase, @vote = :day, {} if @roles.empty?

    role
  end

  def propose_lynch_target(address, target)
    raise if @proposed_for_lynch || !players.include?(target)

    puts "#{address} ((#{@players[address]})) " +
      "proposed #{target} ((#{@players[target]})) for lynching"

    @proposed_for_lynch = target
  end

  def cast_day_vote(address, vote)
    raise if @vote[address] || !@proposed_for_lynch

    @vote[address] = vote

    process_day_vote if @vote.count == @players.count
  end

  def cast_night_vote(address, target)
    raise if @vote[address] || !@players.include?(target) ||
      @players[address] != :werewolf || @phase != :night_2

    @vote[address] = target

    process_night_vote if @vote.count == type_count(:werewolf)
  end

  def cast_heal(address, target)
    raise unless @players[address] == :healer &&
      @players[target] && @phase == :night_1

    @heal = target

    update_state
  end

  def cast_see(address, target)
    raise unless @players[address] == :seer &&
      @players[target] && @phase == :night_1

    @see = true

    update_state

    return @players[target]
  end

  private

  def update_state
    if @phase == :night_1 && (@see || type_count(:seer) == 0) &&
        (@heal || type_count(:healer) == 0)
      @phase = :night_2
      @see = nil
    elsif @phase == :night_2
      check_win_conditions

      @phase = :day
      @heal = nil
    elsif @phase == :day
      check_win_conditions

      if type_count(:healer) > 0 || type_count(:seer) > 0
        @phase = :night_1
      else
        @phase = :night_2
      end
    end
  end

  def process_day_vote
    target = @proposed_for_lynch
    vote_count = @vote.values.select { |v| v }.count

    if vote_count > @players.count.to_f / 2
      puts "#{target} ((#{@players[target]})) is lynched " +
        "with #{vote_count} for and #{@players.count - vote_count} against"

      @players.delete target

      update_state
    else
      puts "#{target} survives " +
        "with #{vote_count} for and #{@players.count - vote_count} against"
    end

    @proposed_for_lynch = nil
    @vote = {}
  end

  def process_night_vote
    pop_votes.any? do |target, count|
      if count == type_count(:werewolf)
        if @heal != target
          puts "#{target} ((#{@players[target]})) is killed"

          @players.delete target
        else
          puts "Someone was saved from the werewolves " +
            "((#{target}, #{@players[target]}))"
        end

        update_state
      end
    end
  end

  def pop_votes
    votes = @vote
      .values
      .group_by { |element| element }
      .map { |key, value| [key, value.count] }
      .to_h

    @vote = {}

    votes
  end

  def type_count(type)
    @players.select { |_, v| v == type }.count
  end

  def check_win_conditions
    werewolf_count = type_count(:werewolf)
    villager_count = type_count(:villager) + type_count(:healer) +
      type_count(:seer)

    villagers_win if werewolf_count == 0
    werewolves_win if werewolf_count >= villager_count
  end

  def villagers_win
    puts
    puts "All of the werewolves are dead"
    puts
    puts "VILLAGERS WIN"

    @winner = :villagers
  end

  def werewolves_win
    if @players.count > type_count(:werewolf)
      puts
      puts "Werewolves come out and kill the remaining villagers"
    end

    puts
    puts "WEREWOLVES WIN"

    @winner = :werewolves
  end
end

def players_by_type(players, type)
  players.select { |_, player_type| player_type == type }.keys
end

results = {:villagers => 0, :werewolves => 0}

1000.times do
  ids = [
    "Pete", "John", "Mary", "Mike", "Jane", "Dave", "Maude", "Melanie",
    "Judy", "Mel", "Sylvia", "Pat", "George", "Nick", "Mat", "Monica"
  ]

  werewolf_count = 2

  game = Game.new werewolf_count, ids.count - werewolf_count - 2

  village = Village.new

  types = {
    :villager => Villager, :werewolf => Werewolf,
    :seer => Seer, :healer => Healer
  }

  ids.map do |id|
    type = game.register_player id

    village.create_player types[type], id
  end

  day_index = 1

  puts village.players.map { |player| [player.id, player.class] }.to_h
  puts
  puts village.count

  while true
    puts
    puts "DAY #{day_index}"
    puts

    while game.phase == :day
      accusor = village.players.sample

      lynch_target = accusor.accuse

      game.propose_lynch_target accusor.id, lynch_target

      village.players.each do |player|
        decision = player == accusor ? true : player.vote(lynch_target)

        game.cast_day_vote player.id, decision
      end
    end

    break if game.winner

    village.sync game.players.keys

    puts
    puts village.count

    puts
    puts "NIGHT #{day_index}"
    puts

    healer = village.healer

    if healer
      healer_target = village.ids.sample

      game.cast_heal healer.id, healer_target

      puts "((Healer #{healer.id} protects #{healer_target}, " +
        "#{village.player_by_id(healer_target).class.to_s.downcase}))"
    else
      healer_target = nil
    end

    seer = village.seer

    if seer
      seer_target = seer.seeing_target

      seeing_result = game.cast_see seer.id, seer_target

      seer.update_knowledge seer_target, seeing_result

      puts "((Seer #{seer.id} visits #{seer_target}, #{seeing_result}"
      puts "  Seer currently knows: #{seer.knowledge}))"
    end

    werewolf_target = village
      .players
      .select { |player| player.class != Werewolf }
      .map(&:id)
      .sample

    village.werewolves.each do |werewolf|
      game.cast_night_vote werewolf.id, werewolf_target
    end

    if werewolf_target == healer_target
      healer.update_knowledge healer_target
    end

    break if game.winner

    village.sync game.players.keys

    puts
    puts village.count

    day_index += 1
  end

  results[game.winner] += 1
end

puts results
