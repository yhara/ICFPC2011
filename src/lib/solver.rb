# -*- coding: utf-8 -*-
# 問題解決用
class Solver
  def initialize
    @i = 2
    @have_j = false
    @left_operations = []
  end

  def solve
    # 以下のreturnを外すと順にこちらのスロットを使って
    # 相手のスロットを攻撃するコードが走る
    return [:left, :I, 0]

    if @left_operations.length > 1
      return @left_operations.shift
    end

    i = @i
    n = (i + 1) * 2
    if @have_j
      j = n + 1
      @have_j = false
      @i += 1
    else
      j = n
      @have_j = true
    end
    @left_operations = attack(1, j, i, 5556)
    return @left_operations.shift
  end

  private

  # numをslotに設定する
  def set_constant(num, slot)
    result = []
    result << [:left, :zero, slot]
    bin = []
    while num > 0
      num, r = num.divmod(2)
      bin << r
    end
    result << [:right, :zero, slot]
    while i=bin.pop
      result << [:left, :succ, slot] if i==1
      result << [:left, :dbl,  slot] unless bin.empty?
    end
    return result
  end

  # i犠牲になるインデックス
  # 255-j攻撃対象のインデックス
  # n犠牲にする体力
  # slotプログラムを組むためのフィールドインデックス
  def attack(slot, i, j, n)
    result = []
    result << [:right, :attack, slot]
    result << [:left, :K, slot]
    result << [:left, :S, slot]
    result << [:right, :get, slot]
    result.concat(set_constant(i, 0))
    result << [:right, :zero, slot]
    result << [:left, :K, slot]
    result << [:left, :S, slot]
    result << [:right, :get, slot]
    result.concat(set_constant(j, 0))
    result << [:right, :zero, slot]
    result << [:left, :K, slot]
    result << [:left, :S, slot]
    result << [:right, :get, slot]
    result.concat(set_constant(n, 0))
    result << [:right, :zero, slot]
    return result
  end
end
