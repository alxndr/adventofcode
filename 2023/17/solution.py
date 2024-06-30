"""
Advent of Code 2023
Day 17: Clumsy Crucible

30k+ iterations...
>>> part1(sample())
102

184mil+ iterations and several minutes of runtime...
# >>> part1(full())
# 665

>>> part2(sample())
94

>>> part2([ '111111111111', '999999999991', '999999999991', '999999999991', '999999999991'])
71

# only ~3 minutes, ~764k iterations!! thanks Djikstra
# >>> part2(full())
# 809
"""

from enum import Enum
from copy import copy
from math import log10
from random import sample as randomize

def part1(input_arr)->int:
    map = strings_to_numbers_arr(input_arr)
    if len(map) != len(map[0]):
        raise Error('ruh roh we want to assume that the map is a square...') # this lets us create the initial_path as a diagonal
    working_paths:list[Crucible] = []
    visited:dict[tuple, dict] = {} # coordinate tuple as key, value is: another dict, Dir as key, value is: another dict, num-of-consecutive-identical-moves as key, value is the lowest-seen heat-loss value for that combo of direction+number_of_consecutive_moves
    initial_path:Crucible = Crucible(map)
    while not initial_path.isAtEnd():
        working_paths.append(Crucible(map, from_path=initial_path))
        # because we know the map is a square, we can skip the canMove checks and instead just alternate between Dir.E and Dir.S...
        dir = Dir.E if len(initial_path.route) == 0 or initial_path.route[-1] == Dir.S else Dir.S
        initial_path.move(dir)
        visited.setdefault(initial_path.coords(), {})[dir] = {initial_path.numOfIdenticalMoves(): initial_path.value}
    lowest_value = initial_path.value
    lowest_value_path = initial_path
    i = 0
    while len(working_paths):
        path = working_paths.pop()
        i += 1
        if i % 10_000_000 == 0 or (i < 10_000_000 and log10(i).is_integer()):
            debug(f'iteration {i}... workin with {len(working_paths)} paths... lowest value?? {lowest_value}')
        if path.isAtEnd():
            if lowest_value == None or path.value < lowest_value:
                lowest_value = path.value
                lowest_value_path = path
            continue
        for dir in Dir.list():
            if path.canMove(dir):
                new_path = Crucible(map, from_path=path)
                new_path.move(dir)
                if lowest_value != None and new_path.value > lowest_value:
                    continue
                coords = new_path.coords()
                # if dir not in visited.setdefault(coords, {}):
                #     visited[coords][dir] = {}
                numMoves = new_path.numOfIdenticalMoves()
                # if numMoves not in visited[coords][dir] or visited[coords][dir][numMoves] > new_path.value:
                if numMoves not in visited.setdefault(coords, {}).setdefault(dir, {}) \
                or visited[coords][dir][numMoves] > new_path.value:
                    visited[coords][dir][numMoves] = new_path.value
                    working_paths.append(new_path)
    debug(f'{i} iterations to find lowest value: {lowest_value}, the path is {len(lowest_value_path.route)} steps long')
    return lowest_value

def part2(input_arr:list[str])->int:
    map = strings_to_numbers_arr(input_arr)
    graph:dict = {'h': len(map), 'w': len(map[0]), 'destY': len(map) - 1, 'destX': len(map[0]) - 1}
    for y in range(graph['h']):
        for x in range(graph['w']):
            graph[x,y] = GraphNode(x=x, y=y, val=map[y][x])
    paths:list[UltraCruciblePath] = [UltraCruciblePath(x=0, y=0, heatLoss=0, lastDir=None, stepsInDir=0, map=map)]
    lowest_heat_loss_path = None
    best_path = None
    i = 0
    while len(paths):
        i += 1
        # if i % 1_000_000 == 0 or (i < 1_000_000 and log10(i).is_integer()):
        #     debug(f'i:{i}... {len(paths)} paths... lowest value: {lowest_heat_loss_path}')
        path = paths.pop(0)
        if path.x == graph['destX'] and path.y == graph['destY']: # we are at the end!!
            # "Once an ultra crucible starts moving in a direction, it needs to move a minimum of four blocks in that direction … (even before it can stop at the end)"
            if path.stepsInDir >= 4 and (lowest_heat_loss_path == None or path.heatLoss < lowest_heat_loss_path):
                lowest_heat_loss_path = path.heatLoss
                best_path = path
            continue
        # we are not at the end yet...
        for dir in Dir.list():
            if path.canMove(dir, graph):
                new_path = UltraCruciblePath(path)
                new_path.move(dir, graph)
                new_path_coords = new_path.coords()
                if new_path.stepsInDir not in graph[new_path_coords].visitors.setdefault(dir, {}) \
                or graph[new_path_coords].visitors[dir][new_path.stepsInDir] > new_path.heatLoss:
                    graph[new_path_coords].visitors[dir][new_path.stepsInDir] = new_path.heatLoss
                    paths.append(new_path)
        paths.sort(key=lambda path: path.heatLoss) # keep paths sorted by heatLoss, lowest-to-highest
    debug(f'{i} iterations, found best path with {len(best_path.route)} steps.....')
    # debug(repr(best_path))
    return lowest_heat_loss_path

class GraphNode:
    def __init__(self, **kwargs):
        self.x = kwargs['x']
        self.y = kwargs['y']
        self.val = kwargs['val']
        self.visitors = {} # keys are Dir, values are dict: with keys num-of-steps, values are min heat loss for that direction & num-of-steps
    def __repr__(self)->str:
        return f'{self.x},{self.y}: {self.val}'

def strings_to_numbers_arr(a:list[str])->list[list[int]]:
    """
    >>> strings_to_numbers_arr(['1234', '3245345'])
    [[1, 2, 3, 4], [3, 2, 4, 5, 3, 4, 5]]
    """
    return [[int(num_str) for num_str in list(nums_str)] for nums_str in a]

class Dir(Enum):
    E = 'E'
    S = 'S'
    W = 'W'
    N = 'N'
    def __repr__(self)->str:
        return self.name
    def __str__(self)->str:
        match self:
            case Dir.E: return '→'
            case Dir.S: return '↓'
            case Dir.W: return '←'
            case Dir.N: return '↑'
            case _:     raise ValueError
    @classmethod
    def list(cls)->list['Dir']:
        return randomize(list(cls), len(cls))

class Crucible:
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
        mapped = copy(self.map)
        coordX = 0
        coordY = 0
        for move in self.route:
            mapped[coordY][coordX] = str(move)
            match move:
                case Dir.E: coordX += 1
                case Dir.S: coordY += 1
                case Dir.W: coordX -= 1
                case Dir.N: coordY -= 1
        return '\n'.join([''.join([str(v) for v in line]) for line in mapped])
    def __str__(self):
        return f'Crucible v:{self.value} [{','.join([repr(d) for d in self.route])}]'
    def coords(self):
        return (self.posX, self.posY)
    def move(self, dir):
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
            case _: raise ValueError(f'unexpected direction in Crucible move: {dir}')
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
    def numOfIdenticalMoves(self):
        if self.route[-3:-1] == self.route[-1:] * 2:
            return 3
        if self.route[-2:-1] == self.route[-1:]:
            return 2
        return 1
    def isAtEnd(self):
        return self.posX + 1 == self.map_wd and self.posY + 1 == self.map_ht

class UltraCruciblePath:
    def __init__(self, *args, **kwargs):
        if len(args):
            existing_path = args[0]
            self.map = copy(existing_path.map)
            self.x = copy(existing_path.x)
            self.y = copy(existing_path.y)
            self.heatLoss = copy(existing_path.heatLoss)
            self.lastDir = copy(existing_path.lastDir)
            self.stepsInDir = copy(existing_path.stepsInDir)
            self.route = copy(existing_path.route)
        else:
            self.map = kwargs.get('map', None)
            self.x = kwargs.get('x', 0)
            self.y = kwargs.get('y', 0)
            self.heatLoss = kwargs.get('heatLoss', 0)
            self.lastDir = kwargs.get('lastDir', None) # could be derived from route...
            self.stepsInDir = kwargs.get('stepsInDir', 0) # could be derived from route...
            self.route = []
    def __str__(self):
        return f'UltraCruciblePath v:{self.heatLoss} steps:{self.stepsInDir} [{','.join([repr(d) for d in self.route])}]'
    def __repr__(self):
        mapped = copy(self.map)
        coordX = 0
        coordY = 0
        for move in self.route:
            mapped[coordY][coordX] = str(move)
            match move:
                case Dir.E: coordX += 1
                case Dir.S: coordY += 1
                case Dir.W: coordX -= 1
                case Dir.N: coordY -= 1
        return '\n'.join([''.join([str(v) for v in line]) for line in mapped])
    def canMove(self, dir:Dir, graph:dict)->bool: # "Once an ultra crucible starts moving in a direction, it needs to move a minimum of four blocks in that direction before it can turn… can move a maximum of ten consecutive blocks without turning"
        # don't step off the edge; no U-turns…
        match dir:
            case Dir.W:
                if self.lastDir == Dir.E or self.x == 0:              return False
            case Dir.E:
                if self.lastDir == Dir.W or self.x == graph['destX']: return False
            case Dir.N:
                if self.lastDir == Dir.S or self.y == 0:              return False
            case Dir.S:
                if self.lastDir == Dir.N or self.y == graph['destY']: return False
        # if haven't gone 4 steps in the same direction, can't turn to a different direction
        if self.stepsInDir < 4:
            return self.lastDir == None or dir == self.lastDir
        # "can move a maximum of ten consecutive blocks without turning"
        return self.stepsInDir < 10 or dir != self.lastDir
    def move(self, dir:Dir, graph:dict)->None:
        match dir:
            case Dir.N: self.y -= 1
            case Dir.W: self.x -= 1
            case Dir.S: self.y += 1
            case Dir.E: self.x += 1
        self.heatLoss += graph[self.x,self.y].val
        if dir == self.lastDir:
            self.stepsInDir += 1
        else:
            self.lastDir = dir
            self.stepsInDir = 1
        self.route.append(dir)
    def coords(self)->tuple:
        return (self.x, self.y)

def sample()->list[str]:
    """
    Return the sample input, as an array of (trimmed) strings.
    >>> sample()[0]
    '2413432311323'
    """
    from sys import stderr
    return file_contents('./sample.txt')

def full()->list[str]:
    """
    Return the full input, as an array of (trimmed) strings.
    >>> full()[-1]
    '211212322131311231132322134223411213222122134314131213545541433115144333341122311253343145513421442314131434121434213141443133322212211323122'
    """
    return file_contents('./input.txt')

def file_contents(filename:str)->list[str]:
    fh = open(filename, 'r')
    input = fh.readlines()
    fh.close
    return [s.strip() for s in input]

def debug(str:str)->None:
    from sys import stderr
    print(str, file=stderr)

if __name__ == '__main__':
    import doctest
    print('\n\n')
    doctest.testmod()
    print('\ndone')
