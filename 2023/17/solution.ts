// const IS_DEBUGGING = Boolean(process.env.IS_DEBUGGING) || false

// input's "single digit that represents the amount of heat loss if the crucible enters that block"
// "starting point… is the top-left city block; the destination… is the bottom-right city block"
// "can move at most three blocks in a single direction"

// weighted graph traversal...
// — Dijkstra's Alg isn't quite right here because the route to a node _can_ influence the next available steps...
// — the route can backtrack which means we can't examine all possible routes
//   ↳  instead, find one full route, then ignore any in-progress route which has a value higher than the lowest-value finished route
// — would be good to do this depth first...
//   ↳  start by basic diagonal ESESESESE til @ the end, get a result, then explore other options...

enum Dir { N = 'N', E = 'E', S = 'S', W = 'W' }
type Coordinate = {
  x:number
  y:number
}
const pC = (c:Coordinate) => `(${c.x},${c.y})`
type Move = {
  dir:Dir
  from:Coordinate
  to:Coordinate
}
const pM = (m:Move) => `[${m.dir}: ${pC(m.from)}=>${pC(m.to)}]`

function dirToArrow(d:Dir):string {
  switch (d) {
    case Dir.N: return '⋏'
    case Dir.E: return '≻'
    case Dir.S: return '⋎'
    case Dir.W: return '≺'
  }
}

class Path {
  cursor:Coordinate // current position
  route:Move[]      // past positions
  value:number      // heat loss
  constructor(p?:Path) {
    this.cursor = p ?     p.cursor : {x:0, y:0} // start at (0,0)
    this.route  = p ? [...p.route] : []
    this.value  = p ?     p.value  : 0
  }
  couldMove(dir:Dir, map:Map):boolean {
    if (this.route.slice(-3).filter(m => m.dir === dir).length > 2) { // can't do more than 3 steps in same direction
      console.log('already gone 3 in the direction of', dir)
      return false
    }
    const lastMove = this.route.slice(-1)?.[0]
    switch (dir) { // can't do a u-turn, and can't turn past the edge of the map
      case Dir.N:
        if (lastMove?.dir === Dir.S || this.cursor.y === 0)
          return false
        break
      case Dir.E:
        if (lastMove?.dir === Dir.W || this.cursor.x + 1 === map.width)
          return false
        break
      case Dir.S:
        if (lastMove?.dir === Dir.N || this.cursor.y + 1 === map.height)
          return false
        break
      case Dir.W:
        if (lastMove?.dir === Dir.E || this.cursor.x === 0)
          return false
        break
    }
    return true
  }
  makeMove(dir:Dir, map:Map):Path {
    let nextCoordinate:Coordinate;
    switch (dir) {
      case Dir.N:
        nextCoordinate = {x: this.cursor.x,     y: this.cursor.y - 1}
        break
      case Dir.E:
        nextCoordinate = {x: this.cursor.x + 1, y: this.cursor.y}
        break
      case Dir.S:
        nextCoordinate = {x: this.cursor.x,     y: this.cursor.y + 1}
        break
      case Dir.W:
        nextCoordinate = {x: this.cursor.x - 1, y: this.cursor.y}
        break
    }
    const p = new Path(this)
    p.route.push({dir, from:this.cursor, to:nextCoordinate})
    p.cursor = nextCoordinate
    p.value = this.value + map.at(nextCoordinate)
    return p
  }
  isAtEnd(map:Map):boolean {
    return this.cursor.x === map.width - 1 && this.cursor.y === map.height - 1
  }
  toString():string {
    return 'path:' + this.value + '...\n' + this.route.map(pM).join('\n')
  }
  toGrid(map:Map):string {
    let mapCopy = map.grid.map(row => [...row])
    for (let i in this.route) {
      const move = this.route[i]
      mapCopy[move.from.y][move.from.x] = dirToArrow(move.dir)
    }
    return mapCopy.map(row => row.join('')).join('\n')
  }
}

export class Map {
  grid: string[]
  width: number
  height: number
  constructor(input:string[]) {
    this.grid = input
    this.height = input.length
    this.width = input[0].length
  }
  at(c:Coordinate):number {
    return Number(this.grid[c.y][c.x])
  }
}

export function part1(input:string[]):number {
  const map = new Map(input)
  let firstPath = new Path()
  let otherPaths:Path[] = []
  while (!firstPath.isAtEnd(map)) {
    console.log('firstPath: ' + firstPath.toString())
    if (firstPath.couldMove(Dir.E, map)) otherPaths.push(firstPath.makeMove(Dir.E, map))
    if (firstPath.couldMove(Dir.S, map)) otherPaths.push(firstPath.makeMove(Dir.S, map))
    if (firstPath.couldMove(Dir.W, map)) otherPaths.push(firstPath.makeMove(Dir.W, map))
    if (firstPath.couldMove(Dir.N, map)) otherPaths.push(firstPath.makeMove(Dir.N, map))
    if (firstPath.route.slice(-1)?.[0]?.dir === Dir.E) {
      firstPath = firstPath.makeMove(Dir.S, map)
    } else {
      firstPath = firstPath.makeMove(Dir.E, map)
    }
    console.log(firstPath.toGrid(map))
  }
  let lowestResult = firstPath.value
  while (otherPaths.length) {
    otherPaths = otherPaths.reduce((paths:Path[], p:Path) => {
      // TODO this doesn't reduce the space enough...
      console.log({lowestResult, numPathsRemaining:otherPaths.length})
      if (p.value > lowestResult) {
        console.log('ignoring a path, value too high...')
        return paths
      }
      if (p.couldMove(Dir.E, map)) paths.push(p.makeMove(Dir.E, map))
      if (p.couldMove(Dir.S, map)) paths.push(p.makeMove(Dir.S, map))
      if (p.couldMove(Dir.W, map)) paths.push(p.makeMove(Dir.W, map))
      if (p.couldMove(Dir.N, map)) paths.push(p.makeMove(Dir.N, map))
      return paths
    }, [])
  }
  return lowestResult
}
