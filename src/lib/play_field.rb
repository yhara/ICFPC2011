class PlayField
  def initialize(first_player=:myself)
    @myself = Player.new(:myself)
    @enemy = Player.new(:enemy)
    @trun = 0
    @opponent = @myself
    @proponent = @enemy
    @apply_cnt = 0
  end

  attr_reader :myself, :enemy, :trun, :opponent, :proponent
  attr_accessor :apply_cnt

  def run(lr, card, slot, opts={})
    VM.run(self, lr, card, slot, opts)
  end

  def change_player
  end

  def next_turn
    return [opponent, proponent]
  end

  def before_turn
  end

  def after_turn
  end
end
