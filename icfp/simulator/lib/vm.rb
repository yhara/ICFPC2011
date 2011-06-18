require "play_field"

class VM
  APPLY_CARD_TO_SLOT = "1"
  APPLY_SLOT_TO_CARD = "2"

  def self.setup
    @@field = PlayField.new
  end

  def self.field
    @@field
  end

  def self.run(lr, card, slot, opts={})
    card = card.to_sym
    card = card == :zero ? 0 : [card]
    case lr
    when APPLY_CARD_TO_SLOT
      oslot(slot)[1] = evaluate(card, oslot(slot)[1])
    when APPLY_SLOT_TO_CARD
      oslot(slot)[1] = evaluate(oslot(slot)[1], card)
    else
      raise "lr value #{lr} is invalid"
    end
    puts @@field.opponent if opts[:dump]
  end

  # value describe:
  # function is array: [:K, [:help, [:zero]]]
  # integer: 0..65535
  def self.evaluate(value, arg=nil)
    value ||= []
    @@field.opponent.apply_cnt+=1
    optimize!(value)
    return nil if value.empty?
    return value[0] if value[0].is_a?(Fixnum)
    args = (value[1..-1] + [arg]).compact
    return self.send(value[0], *args)
  end

  # TODO
  def self.optimize!(value)
    return value
  end

  def self.output
  end

  def self.oslot(i)
    @@field.opponent.slots[i]
  end

  def self.pslot(i)
    @@field.proponent.slots[i]
  end

  def self.I(x); x; end

  def self.succ(n)
    return n.succ if n < 65535
    return n
  end

  def self.dbl(n)
    if n < 32768
      n = n * 2
    else
      n = 65535
    end
    return n
  end

  def self.get(i)
    return oslot(i)[1]
  end

  def self.put(x)
    return [:I]
  end

  def self.S(f)
    return [:S2, f]
  end

  def self.S2(f, g)
    return [:S3, f, g]
  end

  def self.S3(f, g, x)
    h = evaluate(f, x)
    y = evaluate(g, x)
    return evaluate(h, y)
  end

  def self.K(x)
    [:K1, x]
  end

  def self.K1(x, y)
    x
  end

  def self.inc(i)
    oslot(i)[0]+=1
    return [:I]
  end

  def self.dec(i)
    pslot(255-i)[0]-=1
    return [:I]
  end

  def self.attack(i)
    [:attack2, i]
  end

  def self.attack2(i, j)
    [:attack3, i, j]
  end

  def self.attack3(i, j, n)
    oslot(i)[0] -= n
    oslot(255-j)[0] -= n * 0.9
    return :I
  end

  def self.help(i)
    [:help2, i]
  end

  def self.help2(i, j)
    [:help3, i, j]
  end

  def self.help3(i, j, n)
    oslot(i)[0] -= n
    oslot(j)[0] += n * 1.1
    return [:I]
  end

  def self.copy(i)
    return pslot(i)[1]
  end

  def self.revive(i)
    oslot(i)[0] = 1 if oslot(i)[0] <= 0 
    return [:I]
  end

  def self.zombie(i)
    [:zombie2, i]
  end

  def self.zombie2(i, x)
    pslot(i)[1] = x
    pslot(i)[0] = -1 if oslot(i)[0] == 0
    return [:I]
  end
end
