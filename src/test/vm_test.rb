# -*- coding: utf-8 -*-
require File.expand_path("test_helper", File.dirname(__FILE__))
require "vm"
require "play_field"

class VMTest < Test::Unit::TestCase
  def test_example1
    VM.simulate(PlayField.new) do |vm|
      vm.run(:right, :inc, 0)
      vm.run(:right, :zero, 0)
      assert_equal [:I], VM.oslot(0).field
      assert_equal 10001, VM.oslot(0).vitality
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
      assert_equal [:I], vm.oslot(0).field
      assert_equal 16, vm.oslot(1).field
    end
  end

  def test_s_k_s_help_zero
    VM.simulate(PlayField.new) do |vm|
      vm.oslot(1).field = 10
      func = [:S3, [:K1, [:S3, [:K1, [:help3, 0, 1]], [:get]]], [:succ]]
      assert_equal [:I], vm.evaluate(func, 0)
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

  def test_dbl
    VM.simulate(PlayField.new) do |vm|
      assert_equal 65526, vm.dbl(32763)
      assert_equal 65535, vm.dbl(32768)
      assert_raise(NativeError) do
        vm.dbl([:I])
      end
    end
  end

  def test_get
    VM.simulate(PlayField.new) do |vm|
      vm.oslot(0).field = 0
      assert_equal 0, vm.get(0)
      assert_equal [:I], vm.get(255)
      assert_raise(IndexError) do
        vm.get(256)
      end
      vm.oslot(0).vitality = 0
      assert_raise(NativeError) do
        vm.get(0)
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
end
