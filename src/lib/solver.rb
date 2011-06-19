# -*- coding: utf-8 -*-
require "world"
require "strategy"
# 問題解決用
class Solver
  # 先読みの深さ
  LOOKAHEAD_DEPTH = 30
  INFINITY = 2 ** 20

  def initialize
    @current_strategy = NilStrategy.new
  end

  def solve
    c, *args = *select_strategy_class
    if @current_strategy.n_left_operations <= 0 ||
        @current_strategy.class != c
      log("change strategy #{c.inspect}")
      @current_strategy = c.new(*args)
    end
    operation = @current_strategy.next_operation
    log(operation.inspect)
    return operation
  end

  private

  def select_strategy_class
    if World.instance.play_field.myself.slots[0].vitality <= 0
      return ReviveZero
    end

    my_dead_slot = World.instance.play_field.myself.slots.detect { |slot|
      slot.vitality <= 0
    }
    if my_dead_slot
      return ReviveSlot, my_dead_slot.slot_no
    end

    enemy_dead_slot = World.instance.play_field.enemy.slots.detect { |slot|
      slot.vitality <= 0
    }
    if !enemy_dead_slot
      return AttackTiredEnemy
    end

    return ZombiePowder, enemy_dead_slot.slot_no
  end

  def _solve
    strategies = []
    if @current_strategy.n_left_operations > 0
      strategies << new_strategy
      Strategy::ALL.each do |strategy_class|
        new_strategy = strategy_class.new
        if @current_strategy.class == strategy_class &&
            @current_strategy.conditions == new_strategy.conditions
          # 戦術の条件が同じなら要らない
          next
        end
        strategies << new_strategy
      end
    else
      strategies = Strategy::ALL.collect(&:new)
    end

    best_strategy = strategies.max { |strategy|
      evaluate_future(World.instance.play_field, :proponent, LOOKAHEAD_DEPTH,
                      strategy.left_operations, 0)
    }
    operation = best_strategy.next_operation
    return operation
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
end
