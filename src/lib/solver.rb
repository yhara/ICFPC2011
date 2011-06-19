# -*- coding: utf-8 -*-
require "world"
require "strategy"
# 問題解決用
class Solver
  def initialize
    @current_strategy = NilStrategy.new
    @copy_zombie_phase = true
  end

  def solve
    c, *args = *select_strategy_class
    if @current_strategy.n_left_operations <= 0 ||
        @current_strategy.class != c
      log("change strategy #{c.inspect}, #{args.inspect}")
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

    my_dead_slot =
      World.instance.play_field.myself.slots.to_a[0 ... World::NUM_SLOTS / 2].detect { |slot|
      slot.vitality <= 0
    }
    if my_dead_slot
      if (2..7).include?(my_dead_slot.slot_no)
        @copy_zombie_phase = false
      end
      return ReviveSlot, my_dead_slot.slot_no
    end

    if World.instance.play_field.enemy.slots[255].vitality == 1
      return KillEnemy255
    end

    enemy_dead_slot = World.instance.play_field.enemy.slots.detect { |slot|
      slot.vitality <= 0
    }
    if !enemy_dead_slot
      return AttackTiredEnemy
    end

    if @copy_zombie_phase
      return CopyZombie, enemy_dead_slot.slot_no
    else
      return ZombiePowder, enemy_dead_slot.slot_no
    end
  end
end
