module Santa

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
    if has_repeated_pair?(str) && has_letter_sandwich?(str)
      :nice
    else
      :naughty
    end
  end

  private

  def self.has_repeated_pair?(str)
    /(..).*\1/.match str
  end

  def self.has_letter_sandwich?(str)
    /(.).\1/.match str
  end

end
