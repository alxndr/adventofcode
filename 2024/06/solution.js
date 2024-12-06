import fs from 'fs'
import {expect, test} from 'bun:test'

const testInput = fs.readFileSync('./sample.txt', 'utf8')
const fullInput = fs.readFileSync('./input.txt', 'utf8')

function processInput(input) {
  return input.trim().split('\n').map(s => s.trim().split(''))
}

const DIRS = {
  N: {x:  0, y: -1, name: 'N', turn: 'E'},
  E: {x:  1, y:  0, name: 'E', turn: 'S'},
  S: {x:  0, y:  1, name: 'S', turn: 'W'},
  W: {x: -1, y:  0, name: 'W', turn: 'N'},
}

function part1(input) {
  const map = processInput(input)
  const mapHeight = map.length
  const mapWidth = map[0].length
  let y = map.findIndex(line => line.includes('^'))
  let x = map[y].findIndex(char => char === '^')
  let dir = DIRS.N
  let visitedCount = 0
  while (x >= 0 && x < mapWidth && y >= 0 && y < mapHeight) {
    if (map[y][x] !== 'X') {
      visitedCount += 1
      map[y][x] = 'X'
    }
    if (map[y+dir.y]?.[x+dir.x] === '#') { // ugh need to add the ?. because it might be out-of-bounds, but that doesn't feel elegant
      dir = DIRS[dir.turn]
    }
    x = x + dir.x
    y = y + dir.y
  }
  return visitedCount
}

const GUARD_WAS_HERE = 'X'

function copyMap(map) {
  const theCopy = []
  map.forEach(mapRow => {
    theCopy.push([...mapRow])
  })
  return theCopy
}

function part2(input) {
  const originalMap = processInput(input)
  const mapHeight = originalMap.length
  const mapWidth = originalMap[0].length
  const startingY = originalMap.findIndex(line => line.includes('^'))
  const startingX = originalMap[startingY].findIndex(char => char === '^')

  // establish the unmodified path — these will be candidates for obstacle locations
  let y = startingY
  let x = startingX
  let dir = DIRS.N
  let map = copyMap(originalMap)
  while (x >= 0 && x < mapWidth && y >= 0 && y < mapHeight) {
    if (map[y][x] !== GUARD_WAS_HERE) {
      map[y][x] = GUARD_WAS_HERE
    }
    if (map[y+dir.y]?.[x+dir.x] === '#') { // ugh
      dir = DIRS[dir.turn]
    }
    x = x + dir.x
    y = y + dir.y
  }
  const obstacleLocationCandidates = map.reduce((candidates, row, rowIndex) => {
    row.reduce((_, char, colIndex) => {
      if (char === GUARD_WAS_HERE && !(colIndex === startingX && rowIndex === startingY)) {
        // don't try to put obstacle at starting point
        candidates.push({x: colIndex, y: rowIndex})
      }
    }, null)
    return candidates
  }, [])
  let obstacleCount = 0
  obstacleLocationCandidates.forEach(({x: obstacleX, y: obstacleY}) => {
    y = startingY
    x = startingX
    dir = DIRS.N
    map = copyMap(originalMap)
    map[obstacleY][obstacleX] = '#'
    // run the thing with loop detection... if it loops, obstacleCount += 1 and run with the next obstacle location
    const visited = Array(mapHeight).fill(null).map(_ => Array(mapWidth).fill(null).map(_ => []))
    while (x >= 0 && x < mapWidth && y >= 0 && y < mapHeight) {
      if (visited[y][x].includes(dir.name)) {
        obstacleCount += 1
        break
      }
      visited[y][x].push(dir.name)
      if (map[y][x] !== GUARD_WAS_HERE) {
        map[y][x] = GUARD_WAS_HERE
      }
      while (map[y+dir.y]?.[x+dir.x] === '#') {
        dir = DIRS[dir.turn]
      }
      x = x + dir.x
      y = y + dir.y
    }
  })
  return obstacleCount
}

test('part1', () => {
  expect(part1(testInput)).toEqual(41)
  expect(part1(fullInput)).toEqual(4776)
})

test('part2', () => {
  expect(part2(testInput)).toEqual(6)
  expect(part2(fullInput)).toBe(1586)
})
