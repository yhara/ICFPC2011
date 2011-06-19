#!/usr/bin/env ruby
require_relative 'helper.rb'
require_relative 'putter.rb'; include Putter

$TRACE=1

=begin
ゾンビにcopyを使わせたい

help_10 みたいな重たい関数があるとして、
攻撃対象をcopyでパラメタライズできれば使い回せるのではないか。

dec(copy(3)) みたいな

S[K(dec)][copy_3][I]
= dec( 11 )

copy_3 = S[K(copy)][K(3)] (引数を渡すとcopy(3)を実行する)

help(i)(j)(n)

help(copy_3)(copy_4)(copy_5)


--
S(K(dec))(S(K(copy))(K(3)))(I)
= K(dec)(I) ( S(K(copy))(K(3))(I) )
= dec ( K(copy)(I)( K(3)(I) ))
= dec ( copy(3) )

=end

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

def zomie_powder(target_slot, opts)
  o "put", 2
  o 2, "zombie"        # 2: zombie
  bind 2, target_slot  # 2: zombie(target_slot)
  bind_func 2, opts[:func]

  #set 2, S[K[S[K[_now_]][get]]][succ][zero][zero]

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
  inc_for_zombie(1, 5)

  make_num 3, 71
  zomie_powder(0, func: 1)
  make_num 3, 81
  zomie_powder(0, func: 1)
  make_num 3, 91
  zomie_powder(0, func: 1)
}
o "I", 255
o "I", 255
