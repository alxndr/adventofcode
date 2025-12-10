# `cd` into this directory and run `pytest`

class FreshIDRange:
    def __init__(self, start:int, end:int):
        self.start = start
        self.end = end
    def __contains__(self, val:int):
        if val >= self.start and val <= self.end:
            return True
        return False

def part1(filename):
    count_of_fresh = 0
    fresh_id_ranges = []
    with open(filename) as f:
        is_processing_top = True
        for line in f.read().splitlines():
            if line == "":
                is_processing_top = False
                continue # skip to next input line, nothing else to process beyond flipping this bit
            if is_processing_top:
                start, end = line.split("-")
                fresh_id_ranges.append(FreshIDRange(int(start), int(end))) # these ranges are inclusive, unlike Python's default `range` fn
            else:
                ingredient_id = int(line)
                for fresh_id_range in fresh_id_ranges:
                    if ingredient_id in fresh_id_range:
                        count_of_fresh += 1
                        break # don't look through any more ranges
    return count_of_fresh

#######################

def test_part1_sample():
    assert part1('sample.txt') == 3

def test_part1_full():
    assert part1('input.txt') == 756

# def test_part2_sample():
#     assert part2('sample.txt') == 'fill in'

# def test_part2_full():
#     assert part2('input.txt') == 'unknown'
