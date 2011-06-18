require "world"

class Player
  def initialize(name=:mine)
    @name = name
    @slots = (0...World::NUM_SLOTS).map{Slot.new}

    def @slots.[](i)
      raise IndexError, "index #{i} outside of array" if i < 0
      return self.fetch(i)
    end
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
