# `cd` into this directory and run `pytest`

START_CHAR = 'S'
BEAM_CHAR = '|'
EMPTY_CHAR = '.'
SPLITTER_CHAR = '^'

class Conway1:
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
                print('>', line)
                splitter_positions = find_splitter_positions(line)
                for splitter_pos in splitter_positions:
                    c.split_at(splitter_pos)
            else: # first run
                c = Conway1(width=len(line), start_location=line.find(START_CHAR))
    return c.count_of_splits

class Conway2:
    '''
    … no longer like the Game of Life tho
    '''
    def __init__(self, width:int, start_location:int):
        self.field = [0] * width
        self.field[start_location] = 1
        self.count_of_timelines = 0
    def __str__(self):
        return f"««{'__'.join(str(i) for i in self.field)}»»"
    def split_at(self, position):
        if self.field[position] == 0:
            return # no beam timelines to split
        count_timelines = self.field[position]
        self.field[position - 1] += count_timelines
        self.field[position    ]  = 0
        self.field[position + 1] += count_timelines
    def total_timelines(self):
        return sum(self.field)

def part2(filename):
    # how many paths through a graph...
    c = None
    with open(filename) as f:
        for line in f.read().splitlines():
            if c:
                print(c)
                print('>', '__'.join(line))
                splitter_positions = find_splitter_positions(line)
                for splitter_pos in splitter_positions:
                    c.split_at(splitter_pos)
            else: # first run
                c = Conway2(width=len(line), start_location=line.find(START_CHAR))
    return c.total_timelines()

#######################

def test_part1_sample():
    assert part1('sample.txt') == 21

def test_part1_full():
    assert part1('input.txt') == 1633

def test_part2_sample():
    assert part2('sample.txt') == 40

def test_part2_full():
    assert part2('input.txt') == 34339203133559
