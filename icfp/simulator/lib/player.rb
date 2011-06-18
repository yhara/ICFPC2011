require "slot"

class Player
  INITIAL_VITALITY = 10000

  def initialize(name=:mine)
    @name = name
    @slots = (0..255).map{Slot.new}

    def @slots.[](i)
      raise IndexError, "index #{i} outside of array" if i < 0
      return self.fetch(i)
    end
  end

  attr_reader :slots, :name
  attr_accessor :apply_cnt

  def to_s
    str = [@name]
    @slots.each_with_index do |s, i|
      unless s[1] == [:I]
        str << "#{i}={#{s[0]},#{s[1]}}"
      end
    end
    return str.join("\n")
  end
end
