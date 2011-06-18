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

  def test_succ
    assert_equal 65535, VM.succ(65534)
    assert_equal 65535, VM.succ(65535)
    assert_raise(NativeError) do
      VM.succ([:I])
    end
  end

  def test_dbl
    assert_equal 65526, VM.dbl(32763)
    assert_equal 65535, VM.dbl(32768)
    assert_raise(NativeError) do
      VM.dbl([:I])
    end
  end

  def test_get
    VM.oslot(0).field = 0
    assert_equal 0, VM.get(0)
    assert_equal [:I], VM.get(255)
    assert_raise(IndexError) do
      VM.get(256)
    end
  end

  def test_S
    assert_equal [:S2, [:I]], VM.S([:I])
    assert_equal [:S3, [:I], [:I]], VM.S2([:I], [:I])
    assert_equal [:I], VM.S3([:I], [:I], [:I])
    assert_equal [:I], VM.S3([:I], [:I], [:I])
    VM.setup
    assert_raise(NativeError) do
      assert_equal [:I], VM.S3([:I], [:I], 0)
    end
    assert_equal 2, VM.play_field.apply_cnt
    VM.setup
    assert_raise(NativeError) do
      assert_equal [:I], VM.S3([:I], 0, 0)
    end
    assert_equal 1, VM.play_field.apply_cnt
    VM.setup
    assert_raise(NativeError) do
      assert_equal [:I], VM.S3(0, 0, 0)
    end
    assert_equal 0, VM.play_field.apply_cnt
  end
end
