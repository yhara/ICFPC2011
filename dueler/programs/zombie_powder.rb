#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require_relative "helper"

# 1: S(K(help(1)(2)))(K(16384))
def help_for_zombie(i, j)
  o "put", 1
  o 1, "help"                          # 1: help
  bind(1, i)                           # 1: help(i)
  bind(1, j)                           # 1: help(i)(j)
  o "K", 1                             # 1: K(help(i)(j))
  o "S", 1                             # 1: S(K(help(i)(j)))
  bind(1, 10000, apply_to_zero: ["K"]) # 1: S(K(help(1)(2)))(K(16384))
end

# 1: S(K(attack(1)(2)))(K(16384))
def attack_for_zombie(i, j)
  o "put", 1
  o 1, "attack"                        # 1: attack
  bind(1, i)                           # 1: attack(i)
  bind(1, j)                           # 1: attack(i)(j)
  o "K", 1                             # 1: K(attack(i)(j))
  o "S", 1                             # 1: S(K(attack(i)(j)))
  bind(1, 10000, apply_to_zero: ["K"]) # 1: S(K(attack(1)(2)))(K(16384))
end

# 送り込むzomibeを準備
# 2: S(K(S(zombie(target_slot))(get)))(succ)(zero)
def zomie_powder(target_slot)
  o "put", 2
  o 2, "zombie"        # 2: zombie
  bind(2, target_slot) # 2: zombie(target_slot)
  o "K", 2             # 2: S(zombie(target_slot))
  o "S", 2             # 2: S(K(zombie(target_slot))))
  o 2, "get"           # 2: S(K(zombie(target_slot)))(get)
  o "K", 2             # 2: K(S(K(zombie(target_slot)))(get))
  o "S", 2             # 2: S(K(S(K(zombie(target_slot)))(get)))
  o 2, "succ"          # 2: S(K(S(K(zombie(target_slot)))(get)))(succ)

  # zobie powder!!!!!!!!!!!!!!!!!!!!
  o 2, "zero"          # s: S(K(S(zombie(target_slot))(get)))(succ)(zero)
  o 2, "zero"
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

def attack(i, j, n)
  o 1, "attack" # 1: attack
  bind(1, i)    # 1: attack(i)
  bind(1, j)    # 1: attack(i)(j)
  bind(1, n)    # 1: attack(i)(j)(n)
end

# 255スロットを確実にぶっ殺す
attack(128, 0, 9000)
attack(129, 0, 9000)

# 最短のケース。52ターンで攻撃可能。
slot1 = 10
target = 1
target.step(2550, 2) do |i|
  help_for_zombie(i, i+1)
  zomie_powder(0)
end
