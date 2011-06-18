require "world"
require "slots"

class Player
  def initialize(name=:mine)
    @name = name
    @slots = Slots.new(World::NUM_SLOTS)
    World::NUM_SLOTS.times{|i| @slots[i] = Slot.new}
  end

  attr_reader :slots, :name

  def to_s
    str = [@name]
    @slots.each_with_index do |s, i|
      unless s.field == [:I]
        str << "#{i}={#{s.vitality},#{s.field}}"
      end
    end
    return str.join("\n")
  end
end
