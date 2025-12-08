# `cd` into this directory and run `pytest`

def parse(filename):
    with open(filename) as f:
        lines = [[c for c in list(s)] for s in f.read().splitlines()]
    return lines

NEIGHBOR_INDICES = [
    [-1, -1],
    [-1,  0],
    [-1,  1],
    [ 0, -1],
    [ 0,  1],
    [ 1, -1],
    [ 1,  0],
    [ 1,  1],
]

PAPER_ROLL = '@'

def part1(filename):
    count_accessible = 0
    content = parse(filename)
    height = len(content)
    width = len(content[0])
    # print(content)
    for row in range(0, height):
        for col in range(0, width):
            char = content[row][col]
            if char == '@':
                neighbors = [content[row+r][col+c]
                             if row+r >= 0
                                and row+r < width
                                and col+c >= 0
                                and col+c < height
                             else '_'
                             for [r, c]
                             in NEIGHBOR_INDICES]
                # print(f'{row}x{col} =\t {" ".join(neighbors)}')
                if neighbors.count(PAPER_ROLL) < 4:
                    count_accessible += 1
    return count_accessible

#######################

def test_part1_sample():
    assert part1('sample.txt') == 13

def test_part1_full():
    assert part1('input.txt') == 1564

# def test_part2_sample():
#     assert part2('sample.txt') == 'unknown'

# def test_part2_full():
#     assert part2('input.txt') == 'unknown'
