# `cd` into this directory and run `pytest`

def parse(filename):
    with open(filename) as f:
        values = [] # will be a 2-D array...
        for line in f.read().splitlines():
            vs = line.split()
            if vs[0] == '*' or vs[0] == '+':
                return values, vs
            else:
                values.append(int(n) for n in vs)
    raise Error('ruh roh')

def part1(filename):
    values, operators = parse(filename)
    results = None
    for values_row in values:
        vs = list(values_row)
        if results:
            for i in range(0, len(vs)):
                if operators[i] == '+':
                    results[i] += vs[i]
                else: # '*'
                    results[i] *= vs[i]
        else:
            results = vs
    return sum(results)

#######################

def test_part1_sample():
    assert part1('sample.txt') == 4277556

def test_part1_full():
    assert part1('input.txt') == 4771265398012

# def test_part2_sample():
#     assert part2('sample.txt') == 'fill in'

# def test_part2_full():
#     assert part2('input.txt') == 'unknown'
