require "world"

class TestPlayField < Test::Unit::TestCase
  def setup
    @play_field = PlayField.new
  end

  def test_run
    @play_field.run(:right, :zero, 0)
    assert_equal 0, @play_field.opponent.slots[0].field
  end
end
