# `cd` into this directory and run `pytest`

def parse(filename):
    with open(filename) as f:
        lines = [[c for c in list(s)] for s in f.read().splitlines()]
    return lines

def part1(filename):
    content = parse(filename)
    return len(content)

#######################

# def test_part1_sample():
#     assert part1('sample.txt') == 'fill in'

# def test_part1_full():
#     assert part1('input.txt') == 'unknown'

# def test_part2_sample():
#     assert part2('sample.txt') == 'fill in'

# def test_part2_full():
#     assert part2('input.txt') == 'unknown'
