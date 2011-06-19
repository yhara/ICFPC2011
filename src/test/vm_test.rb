# -*- coding: utf-8 -*-
require_relative "test_helper"
require "vm"
require "play_field"

class VMTest < Test::Unit::TestCase
  def test_example1
    VM.simulate(PlayField.new) do |vm|
      vm.run(:right, :inc, 0)
      vm.run(:right, :zero, 0)
      assert_equal [:I], VM.pslot(0).field
      assert_equal 10001, VM.pslot(0).vitality
    end
  end

  def test_example2
    VM.simulate(PlayField.new) do |vm|
      vm.run(:right, :help, 0)
      vm.run(:right, :zero, 0)
      vm.run(:left, :K, 0)
      vm.run(:left, :S, 0)
      vm.run(:right, :succ, 0)
      vm.run(:right, :zero, 0)
      vm.run(:right, :zero, 1)
      vm.run(:left, :succ, 1)
      vm.run(:left, :dbl, 1)
      vm.run(:left, :dbl, 1)
      vm.run(:left, :dbl, 1)
      vm.run(:left, :dbl, 1)
      vm.run(:left, :K, 0)
      vm.run(:left, :S, 0)
      vm.run(:right, :get, 0)
      vm.run(:left, :K, 0)
      vm.run(:left, :S, 0)
      vm.run(:right, :succ, 0)
      vm.run(:right, :zero, 0)
      assert_equal [:I], vm.pslot(0).field
      assert_equal 16, vm.pslot(1).field
    end
  end

  # 現状は無限ループになるためコメントアウト。
  # apply_cntのチェックが入れば問題なくなる。
  # def test_loop_dec2
  #   VM.simulate(PlayField.new) do |vm|
  #     vm.run(:right, :get, 0)
  #     vm.run(:left, :S, 0)
  #     vm.run(:right, :dec, 1)
  #     vm.run(:left, :S, 1)
  #     vm.run(:right, :I, 1)
  #     vm.run(:left, :K, 0)
  #     vm.run(:left, :S, 0)
  #     vm.run(:right, :get, 0)
  #     vm.run(:left, :K, 0)
  #     vm.run(:left, :S, 0)
  #     vm.run(:right, :succ, 0)
  #     vm.run(:right, :zero, 0)
  #     vm.run(:right, :zero, 0)
  #     assert_equal 9833, vm.oslot(255).vitality
  #   end
  # end

  def test_s_k_s_help_zero
    VM.simulate(PlayField.new) do |vm|
      vm.pslot(1).field = 10
      func = [:S3, [:K2, [:S3, [:K2, [:help3, 0, 1]], [:get]]], [:succ]]
      assert_equal [:I], vm.evaluate(func, 0)
    end
  end

  def test_run_fail_with_apply_fixnum_to_card
    VM.simulate(PlayField.new) do |vm|
      vm.pslot(0).field = 10
      assert_raise(NativeError) do
        vm.run(:right, :I, 0)
      end
    end
  end

  def test_run_fail_with_apply_zero_to_field
    VM.simulate(PlayField.new) do |vm|
      assert_raise(NativeError) do
        vm.run(:left, :zero, 0)
      end
    end
  end

  def test_s_succ
    VM.simulate(PlayField.new) do |vm|
      (0..65534).each do |i|
        assert_equal(i + 1, vm.succ(i))
      end
      assert_equal(65535, vm.succ(65535))
      assert_raise(NativeError) do
        vm.succ([:I])
      end
    end
  end

  # 仕様の範囲外
  def test_s_succ__outside_specs
    VM.simulate(PlayField.new) do |vm|
      (65536..65600).each do |i|
        assert_raise(LogicError) do
          vm.succ(i)
        end
      end
    end
  end

  def test_s_dbl
    VM.simulate(PlayField.new) do |vm|
      assert_equal 65534, vm.dbl(32767)
      assert_equal 65535, vm.dbl(32768)
      assert_raise(NativeError) do
        vm.dbl([:I])
      end
    end
  end

  # 仕様の範囲外
  def test_s_dbl__outside_specs
    VM.simulate(PlayField.new) do |vm|
      (65536..65600).each do |i|
      assert_raise(LogicError) do
          vm.dbl(i)
        end
      end
    end
  end

  def test_s_get
    VM.simulate(PlayField.new) do |vm|
      vm.pslot(0).field = 0
      assert_equal 0, vm.get(0)
      assert_equal [:I], vm.get(255)
      [256, 32767, 32768, 65535].each do |arg|
        assert_raise(IndexNativeError) do
          vm.get(arg)
        end
      end
      [[:I], [:put, [:I]]].each do |arg|
        assert_raise(NativeError, IndexNativeError) do
          vm.get(arg)
        end
      end
      vm.pslot(0).vitality = 0
      assert_raise(NativeError) do
        vm.get(0)
      end
    end
  end

  def test_s_put
    VM.simulate(PlayField.new) do |vm|
      [-1, 0, 255, 256, 65535, 65536, [:I]].each do |i|
        assert_equal([:I], vm.put(i))
      end
    end
  end

  def test_S
    VM.simulate(PlayField.new) do |vm|
      assert_equal [:S2, [:I]], vm.S([:I])
      assert_equal [:S3, [:I], [:I]], vm.S2([:I], [:I])
      assert_equal [:I], vm.S3([:I], [:I], [:I])
      assert_equal [:I], vm.S3([:I], [:I], [:I])
    end
    VM.simulate(PlayField.new) do |vm|
      assert_raise(NativeError) do
        assert_equal [:I], vm.S3([:I], [:I], 0)
      end
      assert_equal 2, vm.play_field.apply_cnt
    end
    VM.simulate(PlayField.new) do |vm|
      assert_raise(NativeError) do
        assert_equal [:I], vm.S3([:I], 0, 0)
      end
      assert_equal 1, vm.play_field.apply_cnt
    end
    VM.simulate(PlayField.new) do |vm|
      assert_raise(NativeError) do
        assert_equal [:I], vm.S3(0, 0, 0)
      end
      assert_equal 0, vm.play_field.apply_cnt
    end
  end

  def test_K
    VM.simulate(PlayField.new) do |vm|
      assert_equal([:K2, [:I]], vm.K([:I]))
      assert_equal([:I], vm.K2([:I], [:I]))
    end
  end

  def test_help
    VM.simulate(PlayField.new) do |vm|
      assert_raise(NativeError) { vm.help3(0, 1, [:I]) }
      vm.pslot(0).vitality = 1
      assert_raise(NativeError) { vm.help3(0, 1, 2) }

      vm.pslot(0).vitality = 10000
      assert_equal([:help2, [:I]], vm.help([:I]))
      assert_equal([:help3, 0, 1], vm.help2(0, 1))
      assert_equal([:I], vm.help3(0, 1, 1))
      assert_equal(9999,  vm.pslot(0).vitality)
      assert_equal(10001, vm.pslot(1).vitality)
      vm.pslot(0).vitality = 10000
      vm.pslot(1).vitality = 65535
      assert_equal([:I], vm.help3(0, 1, 1))
      assert_equal(9999, vm.pslot(0).vitality)
      assert_equal(65535, vm.pslot(1).vitality)
      
      vm.processing_zombies = true
      vm.pslot(0).vitality = 10000
      vm.pslot(1).vitality = 10000
      assert_equal([:I], vm.help3(0, 1, 1))
      assert_equal(9999, vm.pslot(0).vitality)
      assert_equal(9999, vm.pslot(1).vitality)
      vm.pslot(0).vitality = 10000
      vm.pslot(1).vitality = 0
      assert_equal([:I], vm.help3(0, 1, 1))
      assert_equal(9999, vm.pslot(0).vitality)
      assert_equal(0,    vm.pslot(1).vitality)
      vm.processing_zombies = false
    end
  end

  def test_copy
    VM.simulate(PlayField.new) do |vm|
      assert_equal [:I], vm.copy(0)
      vm.oslot(0).field = 10
      assert_equal(10, vm.copy(0))
      vm.oslot(255).vitality = 0
      vm.zombie2(0, [:K, [:help, [:zero]]])
      assert_equal([:K, [:help, [:zero]]], vm.copy(255))
    end
  end

  def test_revive
    VM.simulate(PlayField.new) do |vm|
      255.times do |i|
        vm.pslot(i).vitality = 0
        vm.revive(i)
        assert_equal(1, vm.pslot(i).vitality)
      end
      [-1, 256, 32767, 32768, 65535].each do |i|
        assert_raise(IndexNativeError) { vm.revive(i) }
      end
    end
  end

  def test_zombie
    VM.simulate(PlayField.new) do |vm|
      assert_raise(NativeError) { vm.zombie2([:I], [:I]) }
      assert_raise(NativeError) { vm.zombie2(0, [:I]) }
      assert_equal([:zombie2, [:I]], vm.zombie([:I]))
      vm.oslot(255).vitality = 0
      assert_equal([:I], vm.zombie2(0, [:I]))
    end
  end

  def test_s_inc
    VM.simulate(PlayField.new) do |vm|
      assert_equal([:I], vm.pslot(0).field)
      assert_equal(10000, vm.pslot(0).vitality)
      initial_and_expects = [
                             [-1, -1],
                             [0, 0],
                             [1, 2],
                             [10000, 10001],
                             [65534, 65535],
                             [65535, 65535]
                            ]
      initial_and_expects.each do |initial, expect|
        vm.pslot(0).vitality = initial
        vm.run(:right, :inc, 0)
        vm.run(:right, :zero, 0)
        assert_equal([:I], vm.pslot(0).field)
        assert_equal(expect, vm.pslot(0).vitality)
      end
    end
  end

  def test_s_inc__processing_zombies
    VM.simulate(PlayField.new) do |vm|
      assert_equal([:I], vm.pslot(0).field)
      assert_equal(10000, vm.pslot(0).vitality)
      initial_and_expects = [
                             [-1, -1],
                             [0, 0],
                             [1, 0],
                             [10000, 9999],
                             [65535, 65534]
                            ]
      initial_and_expects.each do |initial, expect|
        vm.pslot(0).vitality = initial
        vm.processing_zombies = true
        vm.run(:right, :inc, 0)
        vm.run(:right, :zero, 0)
        vm.processing_zombies = false
        assert_equal([:I], vm.pslot(0).field)
        assert_equal(expect, vm.pslot(0).vitality)
      end
    end
  end

  def test_s_inc__not_fixnum
    VM.simulate(PlayField.new) do |vm|
      assert_raise(NativeError) do
        vm.inc([:I])
      end
    end
  end

  def test_s_inc__invalid_slot_number
    VM.simulate(PlayField.new) do |vm|
      [-1, 256].each do |i|
        assert_raise(IndexNativeError) do
          vm.inc(i)
        end
      end
    end
  end

  def test_s_dec
    VM.simulate(PlayField.new) do |vm|
      assert_equal([:I], vm.oslot(255).field)
      assert_equal(10000, vm.oslot(255).vitality)
      initial_and_expects = [
                             [-1, -1],
                             [0, 0],
                             [1, 0],
                             [10000, 9999],
                             [65535, 65534]
                            ]
      initial_and_expects.each do |initial, expect|
        vm.oslot(255).vitality = initial
        vm.run(:right, :dec, 0)
        vm.run(:right, :zero, 0)
        assert_equal([:I], vm.oslot(255).field)
        assert_equal(expect, vm.oslot(255).vitality)
      end
    end
  end

  def test_s_dec__processing_zombies
    VM.simulate(PlayField.new) do |vm|
      assert_equal([:I], vm.oslot(255).field)
      assert_equal(10000, vm.oslot(255).vitality)
      initial_and_expects = [
                             [-1, -1],
                             [0, 0],
                             [1, 2],
                             [10000, 10001],
                             [65534, 65535],
                             [65535, 65535]
                            ]
      initial_and_expects.each do |initial, expect|
        vm.oslot(255).vitality = initial
        vm.processing_zombies = true
        vm.run(:right, :dec, 0)
        vm.run(:right, :zero, 0)
        vm.processing_zombies = false
        assert_equal([:I], vm.oslot(255).field)
        assert_equal(expect, vm.oslot(255).vitality)
      end
    end
  end

  def test_s_dec__not_fixnum
    VM.simulate(PlayField.new) do |vm|
      assert_raise(NativeError) do
        vm.dec([:I])
      end
    end
  end

  def test_s_dec__invalid_slot_number
    VM.simulate(PlayField.new) do |vm|
      [-1, 256].each do |i|
        assert_raise(IndexNativeError) do
          vm.dec(i)
        end
      end
    end
  end

  def test_zombies_b
    # --- 準備 ---
    play_field = PlayField.new(:myself)

    #0: dec(0)
    play_field.proponent.slots[0].vitality = -1
    play_field.proponent.slots[0].field = [:S3, [:K2, [:dec]], [:K2, 0]]

    #1: get -> ゾンビ処理によってIが渡されてエラーになる
    play_field.proponent.slots[1].vitality = -1
    play_field.proponent.slots[1].field = [:get]

    #2: inc(3)
    play_field.proponent.slots[2].vitality = -1
    play_field.proponent.slots[2].field = [:S3, [:K2, [:inc]], [:K2, 3]]

    # --- ゾンビ処理 ---
    VM.zombies!(play_field)

    # --- 結果 ---
    #0: dec(0)
    assert_equal(0, play_field.proponent.slots[0].vitality)
    assert_equal([:I], play_field.proponent.slots[0].field)
    assert_equal(10001, play_field.opponent.slots[255 - 0].vitality)
    
    #1: get: 何もしない
    assert_equal(0, play_field.proponent.slots[1].vitality)
    assert_equal([:I], play_field.proponent.slots[1].field)

    #2: inc(3)
    assert_equal(0, play_field.proponent.slots[2].vitality)
    assert_equal([:I], play_field.proponent.slots[2].field)
    assert_equal(9999, play_field.proponent.slots[3].vitality)
  end

  def test_s_attack
    VM.simulate(PlayField.new) do |vm|
      assert_equal([:attack2, 0], vm.attack(0))
      assert_equal([:attack3, 0, 0], vm.attack2(0, 0))
      assert_equal([:I], vm.attack3(0, 0, 0))
      base_damage = 10
      p_initials = [10, 11, 65534, 65535]
      p_initials.each do |initial|
        vm.pslot(0).vitality = initial
        vm.attack3(0, 0, base_damage)
        assert_equal(initial - base_damage, vm.pslot(0).vitality)
      end
      o_initial_and_expects = [
                               [1, 0],
                               [9, 0],
                               [10, 1],
                               [10000, 9991],
                               [65534, 65525],
                               [65535, 65526]
                              ]
      o_initial_and_expects.each do |initial, expect|
        vm.oslot(255).vitality = initial
        vm.attack3(0, 0, base_damage)
        assert_equal(expect, vm.oslot(255).vitality)
      end
    end
  end

  def test_s_attack__raise_error
    VM.simulate(PlayField.new) do |vm|
      assert_raise(NativeError) do
        vm.attack3(0, 0, [:I])
      end
      initials = [1, 10000, 65534]
      initials.each do |initial|
        assert_raise(NativeError) do
          vm.pslot(0).vitality = initial
          vm.attack3(0, 0, initial + 1)
        end
      end
    end
  end

  def test_s_attack__processing_zombies
    VM.simulate(PlayField.new) do |vm|
      base_value = 10
      o_initial_and_expects = [
                               [-1, -1],
                               [0, 0],
                               [1, 10],
                               [10000, 10009],
                               [65525, 65534],
                               [65526, 65535],
                               [65527, 65535],
                               [65534, 65535],
                               [65535, 65535],
                              ]
      o_initial_and_expects.each do |initial, expect|
        vm.oslot(255).vitality = initial
        vm.processing_zombies = true
        vm.attack3(0, 0, base_value)
        vm.processing_zombies = false
        assert_equal(expect, vm.oslot(255).vitality)
      end
    end
  end
end
