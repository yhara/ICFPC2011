module Putter
  class FuncName
    def initialize(name)
      @name = name
    end
    attr_reader :name

    def [](arg)
      Appli.new(self, arg)
    end

    def ast
      @name
    end

    def putter(slot)
      [
        [:left, :put, slot],
        [:right, slot, @name]
      ]
    end
  end

  class Appli
    def initialize(left, right)
      @left, @right = left, right
    end

    def [](arg)
      Appli.new(self, arg)
    end

    def ast
      [@left.ast, @right.ast]
    end

    def putter(slot)
      case 
      when Appli === @left && Appli === @right
        raise "cannot generate opecodes for this expr"
      when Appli === @left
        ops = @left.putter(slot)
        ops << [:right, slot, @right.name]
        ops
      when Appli === @right
        ops = @right.putter(slot)
        ops << [:left, @left.name, slot]
        ops
      else
        [
          [:left, :put, slot],
          [:right, slot, @right.name],
          [:left, @left.name, slot]
        ]
      end
    end
  end

  [:S, :K, :I].each do |name|
    const_set(name, FuncName.new(name))
  end
  [:zero, :succ, :dbl, :get, :put, :inc, :dec, :attack,
    :help, :copy, :revive, :zombie].each do |name|
    define_method(name){
      return FuncName.new(name)
    }
  end

  def set(slot, tree)
    tree.putter(slot).each do |a, b, c|
      command ((a==:left) ? "1" : "2"), b, c
    end
  end
end

if $0==__FILE__
  include Putter

  def command(a, b, c)
    puts a
    puts b
    puts c
  end

  set 0, S[K[S[K[S[get]]][get]]][succ]
end
