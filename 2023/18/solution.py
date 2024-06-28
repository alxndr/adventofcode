"""
Advent Of Code https://adventofcode.com
2023 Day 18: Lavaduct Lagoon

#>>> part1(sample())
62

#>>> part1(full())
'foo'
"""

def debug(str):
    from sys import stderr
    print(str, file=stderr)

def expand_plan(plan, coords): ### ensure that dig_plan contains the max (x,y) coords
    new_x, new_y = coords
    while len(plan) < new_y + 1:
        plan.append(['.'] * (new_y + 1 - len(plan))) # can't use extend cause that sets the same array-of-chars in multiple lines
    for line in plan:
        if len(line) < new_x + 1:
            line.extend(['.'] * (new_x + 1 - len(line)))
    ### no return value; modifying plan in-place (pass-by-reference)

def shift_down(plan, how_many): ### digging up past the top of the map
    new_height = len(plan) + how_many
    while len(plan) < new_height:
        plan.insert(0, ['.'] * (len(plan[0])))
    ### no return value; modifying plan in-place (pass-by-reference)

def shift_right(plan, how_many): ### digging left past the edge of the map
    # debug('shift right… %s' % how_many)
    new_width = len(plan[0]) + how_many
    for line in plan:
        for _ in range(0, how_many):
            line.insert(0, '.')
        # debug(line)
    ### no return value; modifying plan in-place (pass-by-reference)

def print_plan(plan):
    debug('\n'.join([''.join(line) for line in plan]) + '\n')

def part1(input):
    processed = process(input)
    dig_plan = [['#']]
    current_x, current_y = 0, 0
    max_x, max_y = 0, 0
    for dig_instruction in processed:
        # debug('\n\t@ %s : %s' % ((current_x, current_y), ' '.join(dig_instruction)))
        direction, distance = dig_instruction[0], int(dig_instruction[1])
        match direction:
            case 'R':
                endpoint_x = current_x + distance
                if endpoint_x > max_x:
                    max_x = endpoint_x
                    expand_plan(dig_plan, (max_x, max_y))
                for digging_x in range(current_x, endpoint_x + 1):
                    dig_plan[current_y][digging_x] = '#'
                current_x = endpoint_x
            case 'L':
                endpoint_x = current_x - distance
                if endpoint_x < 0:
                    abs_endpoint_x = abs(endpoint_x)
                    shift_right(dig_plan, abs_endpoint_x)
                    max_x += abs_endpoint_x
                    endpoint_x = 0
                    current_x += abs_endpoint_x
                for digging_x in range(endpoint_x, current_x):
                    dig_plan[current_y][digging_x] = '#'
                current_x = endpoint_x
            case 'D':
                endpoint_y = current_y + distance
                if endpoint_y > max_y:
                    max_y = endpoint_y
                    expand_plan(dig_plan, (max_x, max_y))
                for digging_y in range(current_y, endpoint_y + 1):
                    dig_plan[digging_y][current_x] = '#'
                current_y = endpoint_y
            case 'U':
                endpoint_y = current_y - distance
                if endpoint_y < 0:
                    abs_endpoint_y = abs(endpoint_y)
                    shift_down(dig_plan, abs_endpoint_y)
                    max_y += abs_endpoint_y
                    endpoint_y = 0
                    current_y += abs_endpoint_y
                for digging_y in range(endpoint_y, current_y):
                    dig_plan[digging_y][current_x] = '#'
                current_y = endpoint_y
            case _:
                raise ValueError('Unexpected direction: "%s"' % direction)
    print_plan(dig_plan)
    return count_interior(dig_plan)

def count_interior(plan):
    """
    >>> count_interior([['.', '#', '#'], ['.', '#', '#'], ['.', '#', '.']])
    5

    Contiguous-to-the-edge considers all edges and handles rectangles...
    >>> count_interior( \
            [ \
                ['.', '#', '.', '.', '.'], \
                ['.', '#', '#', '.', '.'], \
                ['#', '#', '#', '#', '#'], \
                ['.', '#', '#', '.', '.'], \
                ['#', '#', '.', '#', '#'], \
                ['.', '#', '#', '.', '#'], \
                ['.', '#', '.', '.', '#']])
    20

    Contiguous-to-the-edge can go 'around corners'...
    ...this might need to be a proper graph traversal...
    >>> count_interior( \
            [ \
                ['#', '#', '#', '#', '#', '#', '#', '#'], \
                ['#', '.', '.', '.', '.', '.', '.', '#'], \
                ['#', '.', '.', '.', '.', '.', '.', '#'], \
                ['#', '.', '#', '#', '#', '#', '#', '#'], \
                ['#', '.', '#', '.', '.', '.', '.', '#'], \
                ['#', '.', '#', '.', '.', '.', '.', '#'], \
                ['#', '.', '#', '#', '#', '#', '.', '#'], \
                ['#', '.', '.', '.', '.', '#', '.', '#'], \
                ['#', '.', '.', '.', '.', '#', '.', '#'], \
                ['#', '.', '.', '.', '.', '#', '.', '#'], \
                ['#', '.', '.', '.', '.', '#', '.', '#'], \
                ['#', '#', '#', '#', '#', '#', '.', '#']])
    78
    """
    plan_ht = len(plan)
    plan_wd = len(plan[0])
    from math import ceil
    plan_ht_midpt = ceil(plan_ht / 2)
    plan_wd_midpt = ceil(plan_wd / 2)
    # largest_dim = max(plan_ht, plan_wd)
    for y in range(0, plan_ht_midpt):
        for x in range(0, plan_wd_midpt):
            ### erode top edge
            if plan[y][x] == '.' and (y == 0 or plan[y-1][x] == ' '): # left side…
                plan[y][x] = ' '
            if plan[y][plan_wd - x - 1] == '.' and (y == 0 or plan[y-1][plan_wd - x - 1] == ' '): # …right side
                plan[y][plan_wd - x - 1] = ' '
            ### erode bottom edge
            if plan[plan_ht - y - 1][x] == '.' and (y == 0 or plan[plan_ht - y][x] == ' '): # left side…
                plan[plan_ht - y - 1][x] = ' '
            if plan[plan_ht - y - 1][plan_wd - x - 1] == '.' and (y == 0 or plan[plan_ht - y][plan_wd - x - 1] == ' '): # …right side
                plan[plan_ht - y - 1][plan_wd - x - 1] = ' '
    for x in range(0, plan_wd_midpt):
        for y in range(0, plan_ht_midpt):
            ### erode left edge
            if plan[y][x] == '.' and (x == 0 or plan[y][x-1] == ' '): # from the top…
                plan[y][x] = ' '
            if plan[plan_ht - y - 1][x] == '.' and (x == 0 or plan[plan_ht - y - 1][x-1] == ' '): # …from the bottom
                plan[plan_ht - y - 1][x] = ' '
            ### erode right edge
            if plan[y][plan_wd - x - 1] == '.' and (x == 0 or plan[y][plan_wd - x] == ' '): # from the top…
                plan[y][plan_wd - x - 1] = ' '
            if plan[plan_ht - y - 1][plan_wd - x - 1] == '.' and (x == 0 or plan[plan_ht - y - 1][plan_wd - x] == ' '): # …from the bottom
                plan[plan_ht - y - 1][plan_wd - x - 1] = ' '
    print_plan(plan)
    return len(list(filter(lambda v: v != ' ', [x for xs in plan for x in xs])))

def process(input):
    """
    Process lines of input text into tuples.

    >>> process(['R 6 #abc123'])
    [('R', '6', '#abc123')]
    """
    return [tuple(str.split()) for str in input]

def sample():
    """
    Return the sample input.
    >>> sample()[0].strip()
    'R 6 (#70c710)'
    """
    return file_contents('./sample.txt')

def full():
    """
    Return the sample input.
    >>> full()[0].strip()
    'R 4 (#2dbea0)'
    """
    return file_contents('./input.txt')

def file_contents(filename):
    fh = open(filename, 'r')
    input = fh.readlines()
    fh.close
    return input

if __name__ == "__main__":
    import doctest
    doctest.testmod()
