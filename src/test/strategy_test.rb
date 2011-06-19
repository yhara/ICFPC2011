require_relative "test_helper"
require "world"
require "strategy"

class StrategyTest < Test::Unit::TestCase
  def test_zombie_powder
    ZombiePowder.new(255).left_operations
  end
end
