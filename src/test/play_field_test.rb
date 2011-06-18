require_relative "test_helper"
require "world"

class TestPlayField < Test::Unit::TestCase
  def setup
    @play_field = PlayField.new
  end

  def test_run
    @play_field.run(:right, :zero, 0)
    assert_equal(0, @play_field.proponent.slots[0].field)
  end

  def test_apply
    @dup_playfield = @play_field.apply(:right, :zero, 0)
    assert_equal([:I], @play_field.proponent.slots[0].field)
    assert_equal(0, @dup_playfield.proponent.slots[0].field)
  end

  def test_swap_players
    assert_equal(0, @play_field.turn)
    assert_equal(:myself, @play_field.proponent.name)
    assert_equal(:enemy, @play_field.opponent.name)
    @play_field.apply_cnt = 2
    @play_field.swap_players
    assert_equal(:myself, @play_field.opponent.name)
    assert_equal(:enemy, @play_field.proponent.name)
    assert_equal(0, @play_field.apply_cnt)
    @play_field.swap_players
    assert_equal(1, @play_field.turn)
  end
end
