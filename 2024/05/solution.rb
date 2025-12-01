require 'minitest/autorun'

def part1(filename)
  input = File.read(filename).split()
end

describe 'part 1' do
  it 'works' do
    _(part1('./sample.txt')).must_equal 143
  end
end
