# -*- coding: utf-8 -*-
class Strategy
  attr_reader :conditions
  attr_reader :left_operations

  def n_left_operations
    return @left_operations.length
  end

  def next_operation
    return @left_operations.shift
  end

  def take_max_slots(take, myself_or_enemy)
    return myself_or_enemy.sort_by{|slot| -slot.vitality }.take(take)
  end

  def o(arg1, arg2)
    @left_operations ||= []
    if arg1.class == String || arg1.class == Symbol
      apply = :left
      card = arg1
      slot = arg2
    else
      apply = :right
      card = arg2
      slot = arg1
    end
    return @left_operations << [apply, arg1, arg2]
  end

  # スロット番号を生成する場合、2**nの位置を指定するとターン数を減らせる
  def make_num(slot, num)
    o "put", slot
    bin = []
    while num > 0
      num, r = num.divmod(2)
      bin << r
    end
    o slot, "zero"
    while i=bin.pop
      o "succ", slot if i==1
      o "dbl",  slot unless bin.empty?
    end
  end

  # 指定するスロットのcardの引数に指定した数値をbindする
  def bind(slot, num, options={})
    make_num(0, num)
    options[:apply_to_zero] ||= []
    options[:apply_to_zero].each do |card|
      o card, 0
    end
    o "K", slot      # s: K(card)
    o "S", slot      # s: S(K(card))
    o slot, "get"    # s: S(K(card))(get)
    o slot, "zero"   # s: S(K(card))(get)(zero) => card(i)
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
      pf.enemy.slots.each_with_index.min_by {
      |slot, i|
      [slot.vitality, -i]
    }
    max_my_slot, max_my_slot_index =
      pf.myself.slots.to_a[World::NUM_SLOTS / 2 ... pf.myself.slots.length].each_with_index.max_by {
      |slot, i|
      [slot.vitality, -i]
    }
    tmp_slot_index = 1
    # TODO: min_enemy_slotを超える必要はない
    # TODO: 2のn乗にまるめるのが効率いい
    damage = max_my_slot.vitality - 1

    # @conditionsには，一致する戦略かどうかを判定するための情報を含める．
    # AttackTiredEnemyの場合は操作を生成するための
    # メソッド引数全部を指定することによって，後で生成されたものが同じ
    # 戦略かどうかを判定できるようにしてある．
    @conditions = [tmp_slot_index,
                   max_my_slot_index,
                   World::NUM_SLOTS - 1 - min_enemy_slot_index,
                   damage]

    # @left_operationsには，実際にこの戦略で操作する内容を記述する．
    # ex. [[:left, :attack, 10], [:right, :I, 10], ...]
    @left_operations = attack(*conditions)
    @left_operations.unshift([:left, :put, tmp_slot_index])
  end

  # numをslotに設定する
  def set_constant(num, slot)
    result = []
    result << [:left, :put, slot]
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

# 0スロットを生き返らせる
class ReviveZero < Strategy
  def initialize
    pf = World.instance.play_field
    slot = nil
    pf.myself.slots.each_with_index do |s, i|
      next if i==0
      if s.field == [:I]
        slot = i
        break
      end
    end
    if slot.nil?
      slot = 1
      o "put", slot
    end
    o slot, "revive"
    o slot, "zero"
  end
end

class ReviveSlot < Strategy
  # * slot_index - 復活させたいスロット
  def initialize(slot_index)
    pf = World.instance.play_field
    if slot_index == 1
      slot = 0
      o "put", slot if pf.myself.slots[slot].field == [:I]
      o slot, "revive"
      o "K", slot
      o "S", slot
      o slot, "succ"
      o slot, "zero"
    else
      slot = 1
      o "put", slot if pf.myself.slots[slot].field == [:I]
      make_num(0, slot_index)
      o slot, "revive"
      o "K", slot
      o "S", slot
      o slot, "get"
      o slot, "zero"
    end
  end
end

# ゾンビを送り込む
class ZombiePowder < Strategy
  @@zombie_evac_count = 0
  def initialize(dead_slot_no=255)
    pf = World.instance.play_field

    # 相手フィールドの元気な2つを攻撃。help置き場はランダム。
    h_index = rand(127)+1
    fs, ss = take_max_slots(h_index, pf.enemy.slots)
    sirial_help_for_zombie(h_index, fs.slot_no, ss.slot_no, fs.vitality)

    # zombie置き場もランダム。対象は引数からもらう。
    z_index = rand(127)+1
    loop{ z_index = rand(127)+1 } if z_index == h_index

    # 十回に一度はフィールドを持っているslotを狙う
    if (@@zombie_evac_count % 10) == 0
      s = pf.enemy.slots.map{|s| s if s.field != [:I]}.sample(1).first
      dead_slot_no = s unless s.nil?
    end
    zombie_powder(z_index, dead_slot_no, h_index)
    @@zombie_evac_count += 1
  end

  def sirial_help_for_zombie(s, i, j, v)
    o "put", s
    o s, "help"                          # 1: help
    bind(s, i)                           # 1: help(i)
    bind(s, j)                           # 1: help(i)(j)
    o "K", s                             # 1: K(help(i)(j))
    o "S", s                             # 1: S(K(help(i)(j)))
    bind(s, v, apply_to_zero: ["K"])     # 1: S(K(help(i)(j)))(K(v))
  end

  # 送り込むzomibeを準備
  # 2: S(K(S(zombie(target_slot))(get)))(succ)(zero)
  def zombie_powder(use_slot, target_slot, h_index)
    o "put", use_slot
    o use_slot, "zombie"            # 2: zombie
    bind(use_slot, 255-target_slot) # 2: zombie(target_slot)
    o "K", use_slot                 # 2: S(zombie(target_slot))
    o "S", use_slot                 # 2: S(K(zombie(target_slot))))
    o use_slot, "get"               # 2: S(K(zombie(target_slot)))(get)
    o "K", use_slot                 # 2: K(S(K(zombie(target_slot)))(get))
    o "S", use_slot                 # 2: S(K(S(K(zombie(target_slot)))(get)))
    make_num 0, h_index
    o use_slot, "get"

    # zombie powder!!!!!!!!!!!!!!1
    o use_slot, "zero"
  end
end

class Strategy
  ALL = [AttackTiredEnemy, ZombiePowder]
end
