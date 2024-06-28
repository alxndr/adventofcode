"""
Advent Of Code https://adventofcode.com
2023 Day 18: Lavaduct Lagoon

#>>> part1(sample())
62

>>> part1(full())
62365

>>> part2(sample())
952408144115
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
    new_width = len(plan[0]) + how_many
    for line in plan:
        for _ in range(0, how_many):
            line.insert(0, '.')
    ### no return value; modifying plan in-place (pass-by-reference)

def print_plan(plan):
    debug('\n'.join([''.join(line) for line in plan]) + '\n')

def follow_instructions(dig_instructions):
    dig_plan = [['#']]
    current_x, current_y = 0, 0
    max_x, max_y = 0, 0
    for dig_instruction in dig_instructions:
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
    return dig_plan

def part1(input):
    dig_instructions = process(input)
    dig_plan = follow_instructions(dig_instructions)
    return count_interior(dig_plan)

def part2(input):
    dig_instructions = process2(input)
    debug(dig_instructions)
    dig_plan = follow_instructions(dig_instructions) # TODO this is not gonna work...
    debug(f'dig plan is {len(dig_plan[0])} wide x {len(dig_plan)} tall...')
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
    >>> count_interior( \
            [ \
                ['#', '#', '#', '#', '#', '#', '#', '#'], \
                ['#', '.', '.', '.', '.', '.', '.', '#'], \
                ['#', '.', '.', '.', '.', '.', '.', '#'], \
                ['#', '.', '#', '#', '#', '#', '#', '#'], \
                ['#', '.', '#', '.', '.', '.', '.', '#'], \
                ['#', '.', '#', '.', '.', '.', '.', '#'], \
                ['#', '.', '#', '.', '#', '#', '.', '#'], \
                ['#', '.', '#', '#', '#', '#', '.', '#'], \
                ['#', '.', '.', '.', '.', '#', '.', '#'], \
                ['#', '.', '.', '.', '.', '#', '.', '#'], \
                ['#', '.', '.', '.', '.', '#', '.', '#'], \
                ['#', '#', '#', '#', '#', '#', '.', '#']])
    81
    """
    # print_plan(plan)
    plan_ht = len(plan)
    plan_wd = len(plan[0])
    outside = [] # list of (x,y) coords that are outside and need to have their neighbors looked at
    for x in range(0, plan_wd):
        if plan[0][x] == '.':         ### mark top edge
            outside.append((x, 0))
        if plan[plan_ht-1][x] == '.': ### mark bottom edge
            outside.append((x, plan_ht-1))
    for y in range(0, plan_ht):
        if plan[y][0] == '.':         ### mark left edge
            outside.append((0, y))
        if plan[y][plan_wd-1] == '.': ### mark right edge
            outside.append((plan_wd-1, y))
    # from sys import stderr
    while len(outside):
        # print(outside, file=stderr)
        outside_x, outside_y = outside.pop()
        # debug('outside: (%s,%s)' % (outside_x, outside_y))
        plan[outside_y][outside_x] = ' '
        if outside_y > 0 and plan[outside_y-1][outside_x] == '.':       ### check above
            outside.append((outside_x,outside_y-1))
        if outside_x > 0 and plan[outside_y][outside_x-1] == '.':       ### check left
            outside.append((outside_x-1,outside_y))
        if outside_y < plan_ht - 1 and plan[outside_y+1][outside_x] == '.': ### check below
            outside.append((outside_x,outside_y+1))
        if outside_x < plan_wd - 1 and plan[outside_y][outside_x+1] == '.': ### check right
            outside.append((outside_x+1,outside_y))
    # print_plan(plan)
    return len(list(filter(lambda v: v != ' ', [x for xs in plan for x in xs])))

def process(input):
    """
    Process lines of input text into tuples.
    >>> process(['R 6 (#abc123)'])
    [('R', '6', '(#abc123)')]
    """
    return [tuple(str.split()) for str in input]

def direction_as_numstr_to_str(dir_numstr):
    match dir_numstr:
        case '0': return 'R'
        case '1': return 'D'
        case '2': return 'L'
        case '3': return 'U'
        case   _: raise ValueError(f'Unexpected direction value: "{dir_numstr}"')

def hex_code_to_instruction(hex_str):
    distance_hexstr, dir_numstr = hex_str[:-1], hex_str[-1]
    # debug(f'hex_str:{hex_str} … distance_hexstr:{distance_hexstr}, dir_numstr:{dir_numstr}')
    return (direction_as_numstr_to_str(dir_numstr),
            int(distance_hexstr, 16))

def process2(input):
    """
    Process lines of input text into instruction tuple for part 2...
    >>> process2(['R 6 (#70c710)', 'foo bar (#0dc571)', 'baz quux (#015232)'])
    [('R', 461937), ('D', 56407), ('L', 5411)]
    """
    from re import sub
    return [hex_code_to_instruction(sub(r'^.*\(#(.{6})\)$', r'\1', str)) for str in input]

def sample():
    """
    Return the sample input.
    >>> sample()[0]
    'R 6 (#70c710)'
    """
    return file_contents('./sample.txt')

def full():
    """
    Return the sample input.
    >>> full()[0]
    'R 4 (#2dbea0)'
    """
    return file_contents('./input.txt')

def file_contents(filename):
    fh = open(filename, 'r')
    input = fh.readlines()
    fh.close
    return [s.strip() for s in input]

if __name__ == "__main__":
    import doctest
    doctest.testmod()
