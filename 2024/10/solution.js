import fs from 'fs'
import {expect, test} from 'bun:test'

const sampleInput = fs.readFileSync('./sample.txt', 'utf8')
// const fullInput = fs.readFileSync('./input.txt', 'utf8')

class Trail {
  constructor({x, y, map}) {
    this.x = x
    this.y = y
    this.map = map
    this.path = []
  }
  toString() {
    
  }
}

class Map {
  trailheads
  constructor(input) {
    this.map = input.trim().split('\n').map(s => s.split('').map(Number))
    this.trailheads = this.map
      .reduce((th, line, y) => th.concat(line.reduce((xy, n, x) => n === 0 ? xy.concat({x,y}) : xy, [])), [])
      .map(({x,y}) => new Trail({x, y, map: this.map}))
  }
}

function part1(input) {
  const nodes = new Map(input)
}

test('part 1', () => {
  expect(part1(sampleInput)).toEqual(36)
})
