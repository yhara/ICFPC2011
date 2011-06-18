require_relative "test_helper"
require "world"

class TestPlayField < Test::Unit::TestCase
  def setup
    @play_field = PlayField.new
  end

  def test_run
    @play_field.run(:right, :zero, 0)
    assert_equal 0, @play_field.opponent.slots[0].field
  end

  def test_apply
    @dup_playfield = @play_field.apply(:right, :zero, 0)
    assert_equal [:I], @play_field.opponent.slots[0].field
    assert_equal 0, @dup_playfield.opponent.slots[0].field
  end
end
