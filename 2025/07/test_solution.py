# `cd` into this directory and run `pytest`

START_CHAR = 'S'
BEAM_CHAR = '|'
EMPTY_CHAR = '.'
SPLITTER_CHAR = '^'

class Conway:
    '''
    Sorta like a 1-D version of Conway's Game of Life…
    '''

    def __init__(self, width:int, start_location:int):
        if width <= 0:
            raise Error('need some width')
        if start_location >= width or start_location < 0:
            raise Error('start must be >= 0 and < width')
        self.field = [EMPTY_CHAR] * width
        self.field[start_location] = BEAM_CHAR
        self.count_of_splits = 0

    def __str__(self):
        return f"««{''.join(self.field)}»»"

    def split_at(self, position):
        if self.field[position] != BEAM_CHAR:
            return # no beam to split
        self.field[position - 1] = BEAM_CHAR  # if position > 0 … but we know that doesn't happen
        self.field[position    ] = EMPTY_CHAR # might choke on immediate neighbors splitting … but we THINK that doen't happen
        self.field[position + 1] = BEAM_CHAR  # if position <= len(self.field) … but we know that doesn't happen
        self.count_of_splits += 1

def find_splitter_positions(line):
    print('>', line)
    return [pos
            for pos, char
            in enumerate(line)
            if char == SPLITTER_CHAR]

def part1(filename):
    c = None
    with open(filename) as f:
        for line in f.read().splitlines():
            if c:
                print(c)
                splitter_positions = find_splitter_positions(line)
                for splitter_pos in splitter_positions:
                    c.split_at(splitter_pos)
            else: # first run
                c = Conway(width=len(line), start_location=line.find(START_CHAR))
    return c.count_of_splits

#######################

def test_part1_sample():
    assert part1('sample.txt') == 21

def test_part1_full():
    assert part1('input.txt') == 1633

# def test_part2_sample():
#     assert part2('sample.txt') == 'fill in'

# def test_part2_full():
#     assert part2('input.txt') == 'unknown'
