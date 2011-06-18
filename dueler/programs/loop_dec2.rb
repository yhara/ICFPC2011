#!/usr/bin/env ruby

def command(a, b, c)
  puts a
  puts b
  puts c
end

def o(arg1, arg2)
  apply = arg1.class == String ? 1 : 2
  command apply, arg1, arg2
end

class Capture
  def initialize(&block)
    @ary = []
    instance_eval(&block)
  end
  attr_reader :ary

  def o(arg1, arg2)
    apply = arg1.class == String ? :left : :right
    ary << [apply, arg1, arg2]
  end
end

def capture(&block)
  Capture.new(&block).ary
end

def loop_dec(slot1, slot2)
 capture{

o slot1, "get" #=> get
o "S", slot1   #=> S[get]

o slot2, "dec" # dec
o "S", slot2   # S[dec]
  o slot2, "succ"   # S[dec][I]  

o "K", slot1    #        K[ S[get] ]
o "S", slot1    #     S< K[ S[get] ] >
o slot1, "get"  #     S< K[ S[get] ] ><get>
o "K", slot1    #   K[S< K[ S[get] ] ><get>]
o "S", slot1    # S(K[S< K[ S[get] ] ><get>])
o slot1, "succ" # S(K[S< K[ S[get] ] ><get>])(succ)
o slot1, "zero"
#
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
#                      ( I(I(zero)) )
#                      ( I(I(0)) )
#                      ( I(0) )
#                      ( 0 )
#
o 255, "zero"

}
end

p loop_dec(10, 11)
