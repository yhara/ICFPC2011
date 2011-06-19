#!/usr/bin/env ruby
require_relative 'helper.rb'
require_relative 'putter.rb'; include Putter

$TRACE=1

=begin
ゾンビにcopyを使わせたい

help_10 みたいな重たい関数があるとして、
攻撃対象をcopyでパラメタライズできれば使い回せるのではないか。

dec(copy(3)) みたいな

  S(K(dec))(S(K(copy))(K(3)))(I)
  = K(dec)(I) ( S(K(copy))(K(3))(I) )
  = dec ( K(copy)(I)( K(3)(I) ))
  = dec ( copy(3) )

ではhelpでは？

help(copy_3)(copy_4)(copy_5) を実行させたい。


  S(K(_))(S(K(copy))(K(5)))(I)
  = _(copy(5))

  S(K<help(copy(3))(copy(4))>)(S(K(copy))(K(5)))(I)
  = help(copy(3))(copy(4))>)(S(K(copy))(K(5)))(I)

S[
  S{ S[K(help)][ S(K(copy))(K(3)) ] }{ S(K(copy))(K(4)) }
 ]
 [ 
  S(K(copy))(K(5)) 
 ]

--

=end

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

#def help_for_zombie(i, j)
#  o "put", 1
#  o 1, "help"                          # 1: help
#  bind(1, i)                           # 1: help(i)
#  bind(1, j)                           # 1: help(i)(j)
#  o "K", 1                             # 1: K(help(i)(j))
#  o "S", 1                             # 1: S(K(help(i)(j)))
#  bind(1, 10000, apply_to_zero: ["K"]) # 1: S(K(help(1)(2)))(K(16384))
#end

def zomie_powder(opts) # opts = :func, :target, :tmp
  tmp = opts[:tmp]
  o "put", tmp
  o tmp, "zombie"        # 2: zombie
  bind tmp, (255 - opts[:target])  # 2: zombie(target_slot)
  bind_func tmp, opts[:func]
end

def attack(i, j, n)
  o 1, "attack" # 1: attack
  bind(1, i)    # 1: attack(i)
  bind(1, j)    # 1: attack(i)(j)
  bind(1, n)    # 1: attack(i)(j)(n)
end

# 255スロットを確実にぶっ殺す
attack(128, 0, 9000)
attack(129, 0, 9000)
$stderr.puts "@"*128

# 最短のケース。52ターンで攻撃可能。
target = 0
#target.step(2550, 2) do |i|
1.times{
  help_for_zombie(1, 2, 3, 4, 5, 6)

  make_num 4, 11
  make_num 5, 12
  make_num 6, 13
  zomie_powder(target: 255, func: 1, tmp: 2)

  make_num 4, 21
  make_num 5, 22
  make_num 6, 33
  zomie_powder(target: 255, func: 1, tmp: 2)
}
o "I", 255
o "I", 255
