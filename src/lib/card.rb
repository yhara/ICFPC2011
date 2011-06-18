# -*- coding: utf-8 -*-
# カードを表現する。
module Card
  # Card "I" is the identity function. [Remark: It is called the I
  # combinator and written λx.x in lambda-calculus.]
  def self.I(x); x; end

  # Card "succ" is a function that takes an argument n and returns n+1
  # if n<65535 (or returns 65535 if n=65535). It raises an error if n
  # is not an integer.
  def self.succ(n)
    # TODO_KOUJI: NativeErrorは分かりにくい。もう少し具体的な名前にする。
    # また、errorsではなく、ここでしか呼ばないため、このファイルで定義
    # する。
    raise NativeError, "#{n} is not fixnum." unless n.is_a?(Fixnum)
    return n.succ if n < 65535
    # TODO_KOUJI: 65536以上のときが未定義。65536以上の場合、Fatalな例外
    # を起こして、プログラムにバグがあることが分かるようにしよう。
    return n
  end

  # Card "dbl" is a function that takes an argument n and returns n*2
  # (n times 2) if n<32768 (or returns 65535 if n>=32768). It raises
  # an error if n is not an integer.
  def self.dbl(n)
    raise NativeError, "#{n} is not fixnum." unless n.is_a?(Fixnum)
    if n < 32768
      n = n * 2
    else
      n = 65535
    end
    return n
  end
  
  def self.oslot(index)
    play_field = PlayField.instance
    play_field.oponent
  end

  # Card "get" is a function that takes an argument i and returns the
  # value of the field of the ith slot of the proponent if the slot is
  # alive. It raises an error if i is not a valid slot number or the
  # slot is dead.
  def self.get(i)
    return oslot(i).field
  end

  # Card "put" is a function that takes an (unused) argument and
  # returns the identity function.
  def self.put(x)
    return [:I]
  end

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
  def self.S(f)
    return [:S2, f]
  end

  def self.S2(f, g)
    return [:S3, f, g]
  end

  def self.S3(f, g, x)
    raise NativeError, "#{f} is not function." unless f.is_a?(Array)
    h = evaluate(f, x)
    raise NativeError, "#{g} is not function." unless g.is_a?(Array)
    y = evaluate(g, x)
    raise NativeError, "#{h} is not function." unless h.is_a?(Array)
    return evaluate(h, y)
  end

  # Card "K" is a function that takes an argument x and returns
  # another function, which (when applied) will take another (unused)
  # argument y and return x. [Remark: The first function is called the
  # K combinator and written λx.λy.x in lambda-calculus.]
  def self.K(x)
    [:K1, x]
  end

  def self.K1(x, y)
    x
  end

  # Card "inc" is a function that takes an argument i, and increases
  # by 1 the vitality v of the ith slot of the proponent if v>0 and
  # v<65535, does nothing if v=65535 or v<=0, or raises an error if i
  # is not a valid slot number, and returns the identity function.
  def self.inc(i)
    oslot(i).vitality+=1
    return [:I]
  end

  # Card "dec" is a function that takes an argument i, and decreases
  # by 1 the vitality v of the (255-i)th slot of the opponent if v>0,
  # does nothing if v<=0, or raises an error if i is not a valid slot
  # number, and returns the identity function.
  def self.dec(i)
    pslot(255-i).vitality-=1
    return [:I]
  end

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
  def self.attack(i)
    [:attack2, i]
  end

  def self.attack2(i, j)
    [:attack3, i, j]
  end

  def self.attack3(i, j, n)
    oslot(i).vitality -= n
    oslot(255-j).vitality -= n * 0.9
    return :I
  end

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
  def self.help(i)
    [:help2, i]
  end

  def self.help2(i, j)
    [:help3, i, j]
  end

  def self.help3(i, j, n)
    oslot(i).vitality -= n
    oslot(j).vitality += n * 1.1
    return [:I]
  end

  # Card "copy" is a function that takes an argument i, and returns
  # the value of the field of the ith slot of the opponent. It raises
  # an error if i is not a valid slot number. Note that the slot is
  # ith, not (255-i)th.
  def self.copy(i)
    return pslot(i).field
  end

  # Card "revive" is a function that takes an argument i, sets to 1
  # the vitality v of the ith slot of the proponent if v<=0 (or does
  # nothing if v>0), and returns the identity function. It raises an
  # error if i is not a valid slot number.
  def self.revive(i)
    oslot(i).vitality = 1 if oslot(i).dead?
    return [:I]
  end

  # Card "zombie" is a function that takes an argument i and returns
  # another function, which (when applied) will take another argument
  # x, and overwrite with x the field of the (255-i)th slot of the
  # opponent if the slot is dead, or raise an error if i is not a
  # valid slot number or the slot is alive, and set the vitality of
  # the slot to -1, and return the identity function.
  def self.zombie(i)
    [:zombie2, i]
  end

  def self.zombie2(i, x)
    pslot(i).field = x
    pslot(i).vitality = -1 if oslot(i).vitality == 0
    return [:I]
  end
end
