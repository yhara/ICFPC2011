$:.unshift(File.expand_path("../lib", File.dirname(__FILE__)))

require "test/unit"
require "pp"
require "tempfile"
require "fileutils"
require "stringio"

class Test::Unit::TestCase
  def simulate(vm, file_name)
    path = File.join(File.dirname(__FILE__), "simulate_data", file_name)
    apps = []
    File.open(path) do |f|
      first = true
      expected_player_no = "0"
      while line = f.gets
        if first
          first = false
        else
          vm.play_field.swap_players
          expected_player_no = expected_player_no == "0" ? "1" : "0"
          vm.zombies!(vm.play_field)
        end
        player_no, app_type, card_or_slot1, card_or_slot2 = *line.chomp.split(",")
        assert_equal(expected_player_no, player_no)
        case app_type
        when "1"
          app = [:left, card_or_slot1.to_sym, card_or_slot2.to_i]
        when "2"
          app = [:right, card_or_slot2.to_sym, card_or_slot1.to_i]
        else
          raise
        end
        vm.run(*app)
      end
    end
  end
end
