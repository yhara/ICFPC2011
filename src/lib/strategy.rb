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
    return myself_or_enemy.sort_by{|slot| [-slot.vitality, -slot.slot_no] }.take(take)
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
    return @left_operations << [apply, card.to_sym, slot.to_i]
  end

  def command(a, b, c)
    o(b, c)
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
  
  # スロットtoの関数をスロットfromに適用する
  # 結果はtoに保存される
  # つまり
  #     f[to] = to(from)
  # 0はテンポラリとして破壊される
  # 0を使うのは、適用したい関数を「get[zero]」で取り出せるようにするため
  def bind_func(to, from)
    make_num(0, from)  # 0: from
    o "get", 0         # 0: get(from)
                       #  = 引数にしたい関数
  
    o "K", to      # to: K[_]
    o "S", to      # to: S[K[_]]
    o to, "get"    # to: S[K[_]][get]
    o to, "zero"   # to: S[K[_]][get][zero]
                   #  = _( get(0) )
                   #  = 適用したい関数( 引数にしたい関数 )
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
    max_my_slot =
      pf.myself.slots.to_a[World::NUM_SLOTS / 2 ... pf.myself.slots.length].max_by {
      |slot|
      [slot.vitality, -slot.slot_no]
    }
    max_my_slot_index = max_my_slot.slot_no
    tmp_slot_index = 1
    # TODO: min_enemy_slotを超える必要はない
    # TODO: 2のn乗にまるめるのが効率いい
    ideal_damage  = (min_enemy_slot.vitality / 0.9).floor + 1 
    if ideal_damage < max_my_slot.vitality
      damage = ideal_damage
    elsif max_my_slot.vitality > 8192
      damage = 8192
    elsif max_my_slot.vitality > 4096
      damage = 4096
    else
      damage = max_my_slot.vitality / 2
    end

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
    o "put", slot
    o slot, "attack" # 1: attack
    bind(slot, i)    # 1: attack(i)
    bind(slot, j)    # 1: attack(i)(j)
    bind(slot, n)    # 1: attack(i)(j)(n)
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
      o "put", slot if pf.myself.slots[slot].field != [:I]
      o slot, "revive"
      o "K", slot
      o "S", slot
      o slot, "succ"
      o slot, "zero"
    else
      slot = 1
      o "put", slot if pf.myself.slots[slot].field != [:I]
      make_num(0, slot_index)
      o slot, "revive"
      o "K", slot
      o "S", slot
      o slot, "get"
      o slot, "zero"
    end
  end
end

class KillEnemy255 < Strategy
  def initialize
    o "put", 0
    o 0, "dec"
    o 0, "zero"
  end
end

# ゾンビを送り込む
class ZombiePowder < Strategy
  @@zombie_evac_count = 0
  def initialize(dead_slot_no=255)
    pf = World.instance.play_field

    # 相手フィールドの元気な2つを攻撃。help置き場はランダム。
    h_index = rand(127)+1
    fs, ss = take_max_slots(2, pf.enemy.slots)
    sirial_help_for_zombie(h_index, fs.slot_no, ss.slot_no, fs.vitality)

    # zombie置き場もランダム。対象は引数からもらう。
    z_index = rand(127)+1
    loop{
      if z_index == h_index
        z_index = rand(127)+1
      else
        break
      end
    }

    # 十回に一度はフィールドを持っているslotを狙う
    if (@@zombie_evac_count % 10) == 0
      s = pf.enemy.slots.map{|s| s if s.field != [:I]}.sample(1).first
      if s
        dead_slot_no = s.slot_no
      end
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

class CopyZombie < Strategy
  require_relative 'putter.rb'; include Putter
  @@zombie_set = false
  def initialize(target_slot=255)
    unless @@zombie_set
      help_for_zombie(2, 3, 4, 5, 6, 7)
      make_num 5, 0
      make_num 6, 1
      make_num 7, 10000
      @@zombie_set = true
    end
    zomie_powder(target: target_slot, func: 2, tmp: 3)
    o "succ", 5
    o "succ", 5
    o "succ", 6
    o "succ", 6
  end

  def set_lazy_copy(slot, tmp, param) 
    make_num tmp, param     # tmp: 5
    o "K", tmp              # tmp: K(5)

    set slot, S[K[copy]]    # slot: S[K[copy]]
    bind_func slot, tmp     # slot: S[K[copy][K(5)]]
  end

  def help_for_zombie(slot, tmp, tmp2, param1, param2, param3)
    #  S[
    #    S{ S[K(help)][ S(K(copy))(K(3)) ] }{ S(K(copy))(K(4)) }
    #   ]
    #   [  
    #    S(K(copy))(K(5)) 
    #   ]

    set_lazy_copy tmp, tmp2, param1   # tmp: S(K(copy))(K(3))
    set slot, S[K[help]]              # slot:   S[K[help]]
    bind_func slot, tmp               # slot:   S[K[help]][ S(K(copy))(K(3)) ]
    o "S", slot                       # slot: S{S[K[help]][ S(K(copy))(K(3)) ]}

    set_lazy_copy tmp, tmp2, param2   # tmp: S(K(copy))(K(4))
    bind_func slot, tmp               # slot:    S{S[K[help]][ S(K(copy))(K(3)) ]}{ S(K(copy))(K(4)) }
    o "S", slot                       # slot: S[ S{S[K[help]][ S(K(copy))(K(3)) ]}{ S(K(copy))(K(4)) } ]

    set_lazy_copy tmp, tmp2, param3   # tmp: S(K(copy))(K(5))
    bind_func slot, tmp               # slot: S[ ... ][ S(K(copy))(K(5)) ]
  end

  def inc_for_zombie(slot, tmp, param1=3)
    make_num param1, 77

    make_num(slot, param1) # slot: 3
    o "K", slot            # slot: K(3)

    set tmp, S[K[copy]]    # tmp: S[K[copy]]
    bind_func tmp, slot    # tmp: S[K[copy][K(3)]]

    set slot, S[K[inc]]    # slot: S[K[inc]]
    bind_func slot, tmp    # slot: S[K[inc]][ S[K[copy]][K(3)] ]
  end

  def zomie_powder(opts) # opts = :func, :target, :tmp
    tmp = opts[:tmp]
    o "put", tmp
    o tmp, "zombie"        # 2: zombie
    bind tmp, (255 - opts[:target])  # 2: zombie(target_slot)
    bind_func tmp, opts[:func]
  end
end
