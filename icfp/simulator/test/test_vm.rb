class TestRepository < Test::Unit::TestCase
  def setup
    VM.setup
  end

  def test_example1
    VM.run(:right, :inc, 0)
    VM.run(:right, :zero, 0)
    assert_equal [:I], VM.oslot(0).field
    assert_equal 10001, VM.oslot(0).vitality
  end

  def test_example2
    VM.run(:right, :help, 0)
    VM.run(:right, :zero, 0)
    VM.run(:left, :K, 0)
    VM.run(:left, :S, 0)
    VM.run(:right, :succ, 0)
    VM.run(:right, :zero, 0)
    VM.run(:right, :zero, 1)
    VM.run(:left, :succ, 1)
    VM.run(:left, :dbl, 1)
    VM.run(:left, :dbl, 1)
    VM.run(:left, :dbl, 1)
    VM.run(:left, :dbl, 1)
    VM.run(:left, :K, 0)
    VM.run(:left, :S, 0)
    VM.run(:right, :get, 0)
    VM.run(:left, :K, 0)
    VM.run(:left, :S, 0)
    VM.run(:right, :succ, 0)
    VM.run(:right, :zero, 0)
    assert_equal [:I], VM.oslot(0).field
    assert_equal 16, VM.oslot(1).field
  end

  def test_s_k_s_help_zero
    VM.oslot(1).field = 10
    func = [:S3, [:K1, [:S3, [:K1, [:help3, 0, 1]], [:get]]], [:succ]]
    assert_equal [:I], VM.evaluate(func, 0)
  end
end
