class Strategy
  attr_reader :conditions

  def n_left_operations
    return @left_operations.length
  end

  def next_operation
    return @left_operations.shift
  end
end

# なにもしない
class NilStrategy < Strategy
  def initialize
    @conditions = nil
    @left_operations = []
  end
end

# 一番体力が弱い相手へ攻撃
class AttackTiredEnemy < Strategy
  def initialize
    pf = World.instance.play_field

    min_enemy_slot, min_enemy_slot_index =
      pf.enemy.slots.each_with_index.max_by {
      |slot, i|
      [slot.vitality, -i]
    }
    max_my_slot, max_my_slot_index =
      pf.myself.slots.each_with_index.max_by {
      |slot, i|
      [slot.vitality, +i]
    }

    tmp_slot_index =
      (max_my_slot_index - 1 + World::NUM_SLOTS) % World::NUM_SLOTS
    # TODO: min_enemy_slotを超える必要はない
    # TODO: 2のn乗にまるめるのが効率いい
    damage = max_my_slot.vitality - 1

    # @conditionsには，一致する戦略かどうかを判定するための情報を含める．
    # AttackTiredEnemyの場合は操作を生成するための
    # メソッド引数全部を指定することによって，後で生成されたものが同じ
    # 戦略かどうかを判定できるようにしてある．
    @conditions = [tmp_slot_index,
                   max_my_slot_index,
                   World::NUM_SLOTS - min_enemy_slot_index,
                   damage]

    # @left_operationsには，実際にこの戦略で操作する内容を記述する．
    # ex. [[:left, :attack, 10], [:right, :I, 10], ...]
    @left_operations = attack(*conditions)
  end

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

  # slotプログラムを組むためのフィールドインデックス
  # i犠牲になるインデックス
  # World::NUM_SLOTS-j攻撃対象のインデックス
  # n犠牲にする体力
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

class Strategy
  ALL = [AttackTiredEnemy]
end
