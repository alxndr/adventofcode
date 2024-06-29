"""
Advent of Code 2023
Day 17: Clumsy Crucible

>>> part1(sample())
102
"""

from enum import Enum
from copy import copy

def part1(input_arr):
    map = strings_to_numbers_arr(input_arr)
    initial_path = Path(map)
    working_paths = []
    while not initial_path.isAtEnd():
        # add potential moves from here to list of paths to explore
        if initial_path.canMove(Dir.E):
            new_path = Path(map, from_path=initial_path)
            new_path.move(Dir.E)
            working_paths.append(new_path)
        if initial_path.canMove(Dir.S):
            new_path = Path(map, from_path=initial_path)
            new_path.move(Dir.S)
            working_paths.append(new_path)
        if initial_path.canMove(Dir.N):
            new_path = Path(map, from_path=initial_path)
            new_path.move(Dir.N)
            working_paths.append(new_path)
        if initial_path.canMove(Dir.W):
            new_path = Path(map, from_path=initial_path)
            new_path.move(Dir.W)
            working_paths.append(new_path)
        # do the moves for initial_path
        if initial_path.canMove(Dir.E) and (len(initial_path.route) == 0 or initial_path.route[-1] == Dir.S):
            initial_path.move(Dir.E)
        elif initial_path.canMove(Dir.S) and initial_path.route[-1] == Dir.E:
            initial_path.move(Dir.S)
    lowest_value = initial_path.value
    num_paths = 1
    while len(working_paths):
        num_paths += 1
        if num_paths % 9999999 == 0:
            debug(f'iteration {num_paths} ...')
        # debug(f'remaining paths to investigate: #{len(working_paths)}')
        path = working_paths.pop()
        if path.value > lowest_value:
            # debug(f'throwing out {path}')
            continue # no use continuing with this route
        if path.isAtEnd():
            if path.value < lowest_value:
                debug(f'====> new lowest value!! {path} [{num_paths}]')
                lowest_value = path.value
            continue
        # add potential moves from here to list of paths to explore
        if path.canMove(Dir.E):
            new_path = Path(map, from_path=path)
            new_path.move(Dir.E)
            working_paths.append(new_path)
        if path.canMove(Dir.S):
            new_path = Path(map, from_path=path)
            new_path.move(Dir.S)
            working_paths.append(new_path)
        if path.canMove(Dir.N):
            new_path = Path(map, from_path=path)
            new_path.move(Dir.N)
            working_paths.append(new_path)
        if path.canMove(Dir.W):
            new_path = Path(map, from_path=path)
            new_path.move(Dir.W)
            working_paths.append(new_path)
    return lowest_value

def strings_to_numbers_arr(a):
    """
    >>> strings_to_numbers_arr(['1234', '3245345'])
    [[1, 2, 3, 4], [3, 2, 4, 5, 3, 4, 5]]
    """
    return [[int(num_str) for num_str in list(nums_str)] for nums_str in a]

class Dir(Enum):
    N = 'N'
    E = 'E'
    S = 'S'
    W = 'W'
    def __repr__(self):
        return self.name

class Path:
    def __init__(self, map, **kwargs):
        self.map = map
        self.map_ht = len(map)
        self.map_wd = len(map[0])
        if 'from_path' in kwargs:
            self.route = copy(kwargs['from_path'].route)
            self.posX = copy(kwargs['from_path'].posX)
            self.posY = copy(kwargs['from_path'].posY)
            self.value = copy(kwargs['from_path'].value)
        else:
            self.route = []
            self.posX = 0
            self.posY = 0
            self.value = 0
    def __repr__(self):
        return f'Path @({self.posX},{self.posY}) v={self.value} … [{','.join([repr(d) for d in self.route])}]'
    def move(self, dir):
        # debug(f'moving {dir}')
        match dir:
            case Dir.N:
                self.posY -= 1
                self.value += self.map[self.posY][self.posX]
            case Dir.E:
                self.posX += 1
                self.value += self.map[self.posY][self.posX]
            case Dir.S:
                self.posY += 1
                self.value += self.map[self.posY][self.posX]
            case Dir.W:
                self.posX -= 1
                self.value += self.map[self.posY][self.posX]
            case _: raise ValueError(f'unexpected direction in Path#move: {dir}')
        self.route.append(dir)
    def canMove(self, dir):
        match dir:
            case Dir.N:
                if self.posY == 0:               return False # don't step off map
                if self.route[-1:] == [Dir.S]:   return False # no u-turns
            case Dir.E:
                if self.posX + 1 == self.map_wd: return False
                if self.route[-1:] == [Dir.W]:   return False
            case Dir.S:
                if self.posY + 1 == self.map_ht: return False
                if self.route[-1:] == [Dir.N]:   return False
            case Dir.W:
                if self.posX == 0:               return False
                if self.route[-1:] == [Dir.E]:   return False
        if self.route[-3:] == [dir] * 3:
            # can't go more than 3 steps in the same direction
            return False
        return True
    def isAtEnd(self):
        return self.posX + 1 == self.map_wd and self.posY + 1 == self.map_ht

def sample():
    """
    Return the sample input, as an array of (trimmed) strings.
    >>> sample()[0]
    '2413432311323'
    """
    from sys import stderr
    return file_contents('./sample.txt')

def full():
    """
    Return the full input, as an array of (trimmed) strings.
    >>> full()[-1]
    '211212322131311231132322134223411213222122134314131213545541433115144333341122311253343145513421442314131434121434213141443133322212211323122'
    """
    return file_contents('./input.txt')

def file_contents(filename):
    fh = open(filename, 'r')
    input = fh.readlines()
    fh.close
    return [s.strip() for s in input]

def debug(str):
    from sys import stderr
    print(str, file=stderr)

if __name__ == '__main__':
    import doctest
    print('\n\n')
    doctest.testmod()
    print('\ndone')
