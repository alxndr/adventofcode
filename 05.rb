module Santa
  RE_NAUGHTY_SEQUENCES = /ab|cd|pq|xy/
  RE_DOUBLE_LETTERS = /([a-z])\1/
  RE_VOWELS = /[aeiou]/

  def self.load_words
    IO.readlines("./05.txt").map(&:strip)
  end

  def self.count_nice_words(words)
    nice_words(words).size
  end

  def self.nice_words(words)
    words.find_all{|word| naughty_or_nice?(word) == :nice }
  end

  def self.naughty_or_nice?(str)
    if has_naughty_sequences?(str)
      :naughty
    elsif has_two_in_a_row?(str) && has_enough_vowels?(str)
      :nice
    else
      :naughty
    end
  end

  private

  def self.has_enough_vowels?(str)
    str.scan(RE_VOWELS).count > 2
  end

  def self.has_naughty_sequences?(str)
    RE_NAUGHTY_SEQUENCES.match(str)
  end

  def self.has_two_in_a_row?(str)
    RE_DOUBLE_LETTERS.match(str)
  end

end
