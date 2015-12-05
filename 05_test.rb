require "minitest/autorun"

require "./05.rb"

class TestSanta < Minitest::Test
  def test_nice_1
    assert_equal :nice, Santa.naughty_or_nice?("ugknbfddgicrmopn")
  end

  def test_nice_2
    assert_equal :nice, Santa.naughty_or_nice?("aaa")
  end

  def test_naughty_1
    assert_equal :naughty, Santa.naughty_or_nice?("jchzalrnumimnmhp")
  end

  def test_naughty_2
    assert_equal :naughty, Santa.naughty_or_nice?("haegwjzuvuyypxyu")
  end

  def test_naughty_3
    assert_equal :naughty, Santa.naughty_or_nice?("dvszwmarrgswjxmb")
  end

  def test_solution
    assert Santa.count_nice_words(IO.readlines("./05.txt")) < 255
  end

end
