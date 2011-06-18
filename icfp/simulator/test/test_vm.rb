class TestRepository < Test::Unit::TestCase
  def setup
    VM.setup
  end

  def test_example1
    VM.run(VM::APPLY_SLOT_TO_CARD, :inc, 0)
    VM.run(VM::APPLY_SLOT_TO_CARD, :zero, 0)
    assert_equal [:I], VM.oslot(0)[1]
    assert_equal 10001, VM.oslot(0)[0]
  end

  def test_example2
    VM.run(VM::APPLY_SLOT_TO_CARD, :help, 0)
    VM.run(VM::APPLY_SLOT_TO_CARD, :zero, 0)
    VM.run(VM::APPLY_CARD_TO_SLOT, :K, 0)
    VM.run(VM::APPLY_CARD_TO_SLOT, :S, 0)
    VM.run(VM::APPLY_SLOT_TO_CARD, :succ, 0)
    VM.run(VM::APPLY_SLOT_TO_CARD, :zero, 0)
    VM.run(VM::APPLY_SLOT_TO_CARD, :zero, 1)
    VM.run(VM::APPLY_CARD_TO_SLOT, :succ, 1)
    VM.run(VM::APPLY_CARD_TO_SLOT, :dbl, 1)
    VM.run(VM::APPLY_CARD_TO_SLOT, :dbl, 1)
    VM.run(VM::APPLY_CARD_TO_SLOT, :dbl, 1)
    VM.run(VM::APPLY_CARD_TO_SLOT, :dbl, 1)
    VM.run(VM::APPLY_CARD_TO_SLOT, :K, 0)
    VM.run(VM::APPLY_CARD_TO_SLOT, :S, 0)
    VM.run(VM::APPLY_SLOT_TO_CARD, :get, 0)
    VM.run(VM::APPLY_CARD_TO_SLOT, :K, 0)
    VM.run(VM::APPLY_CARD_TO_SLOT, :S, 0)
    VM.run(VM::APPLY_SLOT_TO_CARD, :succ, 0)
    VM.run(VM::APPLY_SLOT_TO_CARD, :zero, 0)
    assert_equal [:I], VM.oslot(0)[1]
    assert_equal 16, VM.oslot(1)[1]
  end

  def test_s_k_s_help_zero
    VM.oslot(1)[1] = 10
    func = [:S3, [:K1, [:S3, [:K1, [:help3, 0, 1]], [:get]]], [:succ]]
    assert_equal [:I], VM.evaluate(func, 0)
  end
end
