require_relative 'person'

class Villager < Person
  def to_s
    super.green
  end
end
