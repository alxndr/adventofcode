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
  let map = processInput(input)
  const mapHeight = map.length
  const mapWidth = map[0].length
  let y = map.findIndex(line => line.includes('^'))
  let x = map[y].findIndex(char => char === '^')
  let dir = DIRS.N
  let count = 0
  while (x >= 0 && x < mapWidth && y >= 0 && y < mapHeight) {
    if (map[y][x] !== 'X') {
      count += 1
      map[y][x] = 'X'
    }
    // console.log(map.map(l => l.join('')).join('\n'), '\n\n\n')
    if (map[y+dir.y]?.[x+dir.x] === '#') { // ugh
      dir = DIRS[dir.turn]
    }
    x = x + dir.x
    y = y + dir.y
  }
  return count
}

test('part1', () => {
  expect(part1(testInput)).toEqual(41)
  expect(part1(fullInput)).toEqual(4776)
})
