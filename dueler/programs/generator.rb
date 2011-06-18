require 'pp'

=begin
任意の関数をフィールドに置くことを考える。

例
    C    まずCを置いたとして
        -> [:right, 0, C]
    C[D] 右に付ける場合はこう
        -> [:left, C, 0]
  D[C]   左に付ける場合はこう
        -> [:right, 0, D]

=end

class Putter
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

  [:S, :K].each do |name|
    const_set(name, FuncName.new(name))
  end
  [:get, :succ].each do |name|
    define_method(name){
      return FuncName.new(name)
    }
  end

  def self.build(slot, &block)
    new(slot, &block).result
  end

  def initialize(slot, &block)
    tree = instance_eval(&block)
    @result = tree.putter(slot)
  end
  attr_reader :result
end

#Putter.build{
#  get
#}

p Putter.build(0){
  S[K[S[K[S[get]]][get]]][succ]
}
