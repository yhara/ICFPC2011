#!/usr/bin/env ruby
require_relative 'putter.rb'; include Putter

def command(a, b, c)
  puts a
  puts b
  puts c
end

def o(arg1, arg2)
  apply = arg1.class == String ? 1 : 2
  command apply, arg1, arg2
end

slot1 = 0
slot2 = 1

set slot2, S[dec][I]
set slot1, S[K[S[K[S[get]]][get]]][succ]

o slot1, "zero"
# S( K[S< K[ S[get] ] ><get>] )(succ)(zero)
# =  K[S< K[ S[get] ] ><get>](zero)(succ(zero))
# =    S< K[ S[get] ] ><get>(succ(zero))
# =    S< K[ S[get] ] ><get>(1)
# =    S< K[ S[get] ] ><get><1>
# = K[S[get]](1)(get(1))
# =   S[get]( S[dec][I] )
#

o slot1, "zero"
# S<get><S[dec][I]><zero>
# = get(zero)( S[dec][I][zero] )
# = get(0)             ( S[dec][I][zero] )
# = S(get)(S(dec)(I))  ( S[dec][I][zero] )
# =        ..          ( dec(0)(I(zero)) )
#                      ( 0 )

o 255, "zero"

