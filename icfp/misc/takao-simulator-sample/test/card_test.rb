# -*- coding: utf-8 -*-

require File.expand_path("test_helper", File.dirname(__FILE__))
require "card"

class CardTest < Test::Unit::TestCase
  def test_s_index
    assert_equal(Card::I, Card["I"])
    assert_equal(Card::Zero, Card["zero"])
    assert_equal(Card::Succ, Card["succ"])
    assert_equal(Card::Dbl, Card["dbl"])
    assert_equal(Card::Get, Card["get"])
    assert_equal(Card::Put, Card["put"])
    assert_equal(Card::S, Card["S"])
    assert_equal(Card::K, Card["K"])
    assert_equal(Card::Inc, Card["inc"])
    assert_equal(Card::Dec, Card["dec"])
    assert_equal(Card::Attack, Card["attack"])
    assert_equal(Card::Help, Card["help"])
    assert_equal(Card::Copy, Card["copy"])
    assert_equal(Card::Revive, Card["revive"])
    assert_equal(Card::Zombie, Card["zombie"])
  end

  # --- 各カード ---
  def test_I
    assert_equal("I", Card::I.name)
    assert_equal(1, Card::I.function.(1))
    assert_equal(Card::I.function, Card::I.function.(Card::I.function))
  end
  
  def test_Zero
    assert_equal("zero", Card::Zero.name)
    assert_equal(0, Card::Zero.function.())
  end

  def test_Succ
    assert_equal("succ", Card::Succ.name)
    (1..65534).each do |i|
      assert_equal(i + 1, Card::Succ.function.(i))
    end
    assert_equal(65535, Card::Succ.function.(65535))
    # 65536には対応する必要がない。
    assert_raises(ArgumentError) do
      Card::Succ.function.(Card::I.function)
    end
  end
end
