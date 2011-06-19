# -*- coding: utf-8 -*-
require "world"
# 問題解決用
class Solver
  # 先読みの深さ
  LOOKAHEAD_DEPTH = 30
  INFINITY = 2 ** 20

  def initialize
    @current_strategy = NilStrategy.new
  end

  def solve
    strategies = []
    if @current_strategy.n_left_operations > 0
      strategies << new_strategy
      STRATEGIES.each do |strategy_class|
        new_strategy = strategy_class.new
        if @current_strategy.class == strategy_class &&
            @current_strategy.conditions == new_strategy.conditions
          # 戦術の条件が同じなら要らない
          next
        end
        strategies << new_strategy
      end
    else
      strategies = STRATEGIES.collect(&:new)
    end

    best_strategy = strategies.max { |strategy|
      evaluate_future(World.instance.play_field, :proponent, LOOKAHEAD_DEPTH,
                      strategy.left_operations, 0)
    }
    operation = best_strategy.next_operation
    return operation
  end

  private

  class Strategy
    attr_reader :conditions

    def n_left_operations
      raise "!"
    end

    def next_operation
      raise "!"
    end

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
      @conditions = [tmp_slot_index,
                     max_my_slot_index,
                     World::NUM_SLOTS - min_enemy_slot_index,
                     damage]
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

  def dec_1000(tmp_slot_1, tmp_slot_2)
    return [[:right, :get, tmp_slot_1],
            [:left, :S, tmp_slot_1],
            [:right, :dec, tmp_slot_2],
            [:left, :S, tmp_slot_2],
            [:right, :succ, tmp_slot_2],
            [:left, :K, tmp_slot_1],
            [:left, :S, tmp_slot_1],
            [:right, :get, tmp_slot_1],
            [:left, :K, tmp_slot_1],
            [:left, :S, tmp_slot_1],
            [:right, :succ, tmp_slot_1],
            [:right, :zero, tmp_slot_1],
            [:right, :zero, tmp_slot_1]]
  end

  # 死亡したスロットをどのぐらい優先して考慮するか
  DEAD_SLOT_SCORE = 1000

  def evaluate(play_field)
    n = 0
    play_field.myself.slots.each do |slot|
      n += slot.vitality
      if slot.vitality <= 0
        n -= DEAD_SLOT_SCORE
      end
    end
    play_field.enemy.slots.each do |slot|
      n -= slot.vitality
      if slot.vitality <= 0
        n += DEAD_SLOT_SCORE
      end
    end
    return n
  end

  def evaluate_future(play_field, p_or_o, depth,
                      p_operations, p_operation_index)
    if depth.zero?
      return evaluate(play_field)
    end

    if p_or_o == :proponent
      next_operation = p_operations[p_operation_index]

      # 次の手がもうないとき
      if next_operation.nil?
        return evaluate(play_field)
      end

      # 次の手を決めている場合
      new_play_field = play_field.apply(next_operation)
      n = evaluate_future(new_play_field, :opponent, depth - 1,
                          p_operations, p_operation_index + 1)
      return n
    end

    # 相手側
    evaluations = []
    each_operations do |operation|
      new_play_field = play_field.apply(*operation)
      n = evaluate_future(new_play_field, :proponent, depth - 1,
                          p_operations, p_operation_index)
      evaluations.push(n)
    end
    return evaluations.min # 相手はこっちにとって最悪の手を打つ
  end

  def each_operations
    [:left, :right].each do |l_or_r|
      CARDS.each do |card|
        (0...World::NUM_SLOTS).each do |slot_index|
          operation = [l_or_r, card, slot_index]
          yield(operation)
        end
      end
    end
  end

  STRATEGIES = [AttackTiredEnemy]
end
