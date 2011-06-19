#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require_relative "helper"

# 1: S(K(help(1)(2)))(K(16384))
def help_for_zombie(i, j, slot)
  o "put", slot
  o slot, "help"                          # 1: help
  bind(slot, i)                           # 1: help(i)
  bind(slot, j)                           # 1: help(i)(j)
  o "K", slot                             # 1: K(help(i)(j))
  o "S", slot                             # 1: S(K(help(i)(j)))
  bind(slot, 10000, apply_to_zero: ["K"]) # 1: S(K(help(1)(2)))(K(16384))
end

# 1: S(K(attack(1)(2)))(K(16384))
def attack_for_zombie(i, j, slot)
  o "put", slot
  o slot, "attack"                        # 1: attack
  bind(slot, i)                           # 1: attack(i)
  bind(slot, j)                           # 1: attack(i)(j)
  o "K", slot                             # 1: K(attack(i)(j))
  o "S", slot                             # 1: S(K(attack(i)(j)))
  bind(slot, 10000, apply_to_zero: ["K"]) # 1: S(K(attack(1)(2)))(K(16384))
end

# 送り込むzombieを準備
# 2: S(K(S(zombie(target_slot))(get)))(succ)(zero)
# * target_slot - 送り込む先のスロット
# * slot - zombieを送り込むために使うスロット
# * func_slot - 送り込む関数が格納されているスロット
def zombie_powder(target_slot, slot, func_slot)
  o "put", slot
  o slot, "zombie"        # 2: zombie
  bind(slot, target_slot) # 2: zombie(target_slot)
  o "K", slot             # 2: S(zombie(target_slot))
  o "S", slot             # 2: S(K(zombie(target_slot))))
  o slot, "get"           # 2: S(K(zombie(target_slot)))(get)
  o "K", slot             # 2: K(S(K(zombie(target_slot)))(get))
  o "S", slot             # 2: S(K(S(K(zombie(target_slot)))(get)))
  make_num 0, func_slot
  o slot, "get"
  # zombie powder!!!!!!!!!!!!!!1
  o slot, "zero"
end

# [:I]を受け取ったときに強力なhelp or attackを呼び出したい
# help(i)(j)(n)
#  v[i] -= n
#  v[j] -= n * 1.1
# i, j, n に強力な数字を保持し、Iで起動するように

# 0で数値を生成する =>
# S(K(attack(by0)(by0)))(K(by0)) => 1において
# S(K(S(K(zombie(zero)))(get)))(succ)(zero)   => 2において
#  f x = > S(K(zombie(zero)))(get)
#  g x = > succ zero => 1
#  h y = > S(K(zombie(zero)))(get)(1) => 
#    f x  = > zombie(zero)
#    g x  = > get 1 => xxx
#    h x  = > zombie(zero)(xxx)

def attack(i, j, n, slot)
  o slot, "attack" # 1: attack
  bind(slot, i)    # 1: attack(i)
  bind(slot, j)    # 1: attack(i)(j)
  bind(slot, n)    # 1: attack(i)(j)(n)
end

slot = 1
# 255スロットを確実にぶっ殺す
attack(128, 0, 8196, slot)
attack(129, 0, 8196, slot)

# 最短のケース。52ターンで攻撃可能。
slot1 = 10
target = 0
help_slot = 1
target.step(2550, 2) do |i|
  help_for_zombie(i, i+1, help_slot)
  zombie_powder(0, slot1, help_slot)
end
