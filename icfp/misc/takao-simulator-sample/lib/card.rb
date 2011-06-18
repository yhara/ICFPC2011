# -*- coding: utf-8 -*-
# 各カードを表現する。
class Card
  # カード名
  attr_accessor :name

  # 効果
  attr_accessor :function

  # 名前からカードへのハッシュ。全てのカードを格納する。
  @@cards = {}

  def initialize(name, function)
    @name = name
    @function = function
    @@cards[name] = self
  end

  def self.[](name)
    return @@cards[name]
  end
  
  # Card "I" is the identity function. [Remark: It is called the I
  # combinator and written λx.x in lambda-calculus.]
  I = new("I", ->(x){ x })
  
  # Card "zero" is an integer constant 0.
  Zero = new("zero", ->(){ 0 })

  # Card "succ" is a function that takes an argument n and returns n+1
  # if n<65535 (or returns 65535 if n=65535). It raises an error if n
  # is not an integer.
  Succ = new("succ", ->(n){
               raise ArgumentError, "`succ' raises an error if n is not an integer. n=<#{n.inspect}>" if !n.kind_of?(Integer)
               n == 65535 ? 65535 : n + 1
             })

  # Card "dbl" is a function that takes an argument n and returns n*2
  # (n times 2) if n<32768 (or returns 65535 if n>=32768). It raises
  # an error if n is not an integer.
  Dbl = new("dbl", ->(x){ x })

  # Card "get" is a function that takes an argument i and returns the
  # value of the field of the ith slot of the proponent if the slot is
  # alive. It raises an error if i is not a valid slot number or the
  # slot is dead.
  Get = new("get", ->(x){ x })
  # テクニカルノート: slotsはWorld.instance.proponent.slots[i]で取る予定。

  # Card "put" is a function that takes an (unused) argument and
  # returns the identity function.
  Put = new("put", ->(x){ x })

  # Card "S" is a function that takes an argument f and returns
  # another function, which (when applied) will take another argument
  # g and return yet another function, which (when applied) will take
  # yet another argument x, apply f to x obtaining a return value h
  # (or raise an error if f is not a function), apply g to x obtaining
  # another return value y (or raise an error if g is not a function),
  # apply h to y obtaining yet another return value z (or raise an
  # error if h is not a function), and return z. [Remark: The first
  # function is called the S combinator and written λf.λg.λx.fx(gx) in
  # lambda-calculus.]
  S = new("S", ->(x){ x })

  # Card "K" is a function that takes an argument x and returns
  # another function, which (when applied) will take another (unused)
  # argument y and return x. [Remark: The first function is called the
  # K combinator and written λx.λy.x in lambda-calculus.]
  K = new("K", ->(x){ x })

  # Card "inc" is a function that takes an argument i, and increases
  # by 1 the vitality v of the ith slot of the proponent if v>0 and
  # v<65535, does nothing if v=65535 or v<=0, or raises an error if i
  # is not a valid slot number, and returns the identity function.
  Inc = new("inc", ->(x){ x })

  # Card "dec" is a function that takes an argument i, and decreases
  # by 1 the vitality v of the (255-i)th slot of the opponent if v>0,
  # does nothing if v<=0, or raises an error if i is not a valid slot
  # number, and returns the identity function.
  Dec = new("dec", ->(x){ x })

  # Card "attack" is a function that takes an argument i and returns
  # another function, which (when applied) will take another argument
  # j and return yet another function, which (when applied) will take
  # yet another argument n, decrease by n the vitality v of the ith
  # slot of the proponent (or raise an error if i is not a valid slot
  # number, n is not an integer, or n is greater than v), and decrease
  # by n*9/10 (n times 9 divided by 10, with the remainder discarded)
  # the vitality w of the (255-j)th slot of the opponent if it is
  # alive (w is set to 0 if it would become less than 0 by this
  # decrease), do nothing if the slot is dead, or raise an error if j
  # is not a valid slot number, and return the identity function.
  Attack = new("attack", ->(x){ x })

  # Card "help" is a function that takes an argument i and returns
  # another function, which (when applied) will take another argument
  # j and return yet another function, which (when applied) will take
  # yet another argument n, decrease by n the vitality v of the ith
  # slot of the proponent (or raise an error if i is not a valid slot
  # number, n is not an integer, or n is greater than v), and increase
  # by n*11/10 (n times 11 divided by 10, with the remainder
  # discarded) the vitality w of the jth slot of the proponent if it
  # is alive (w is set to 65535 if it would become greater than 65535
  # by this increase), do nothing if the slot is dead, or raise an
  # error if j is not a valid slot number, and return the identity
  # function.
  Help = new("help", ->(x){ x })

  # Card "copy" is a function that takes an argument i, and returns
  # the value of the field of the ith slot of the opponent. It raises
  # an error if i is not a valid slot number. Note that the slot is
  # ith, not (255-i)th.
  Copy = new("copy", ->(x){ x })

  # Card "revive" is a function that takes an argument i, sets to 1
  # the vitality v of the ith slot of the proponent if v<=0 (or does
  # nothing if v>0), and returns the identity function. It raises an
  # error if i is not a valid slot number.
  Revive = new("revive", ->(x){ x })

  # Card "zombie" is a function that takes an argument i and returns
  # another function, which (when applied) will take another argument
  # x, and overwrite with x the field of the (255-i)th slot of the
  # opponent if the slot is dead, or raise an error if i is not a
  # valid slot number or the slot is alive, and set the vitality of
  # the slot to -1, and return the identity function.
  Zombie = new("zombie", ->(x){ x })
end
