import fs from 'fs'
import {expect, test} from 'bun:test'

const sampleInput = fs.readFileSync('./sample.txt', 'utf8')
const fullInput = fs.readFileSync('./input.txt', 'utf8')

function processInput(input) {
  const matrix = input.trim().split('\n').map(s => s.trim().split(''))
  const matrixHeight = matrix.length
  const matrixWidth = matrix[0].length
  const antennas = {}
  for (let y = 0; y < matrixHeight; y++)
    for (let x = 0; x < matrixWidth; x++) {
      const frequencyChar = matrix[y][x]
      if (frequencyChar !== '.') {
        if (!antennas[frequencyChar]) antennas[frequencyChar] = []
        antennas[frequencyChar].push({x, y})
      }
    }
  return {
    matrix,
    matrixWidth,
    matrixHeight,
    antennas,
  }
}

function part1(input) {
  function generatePotentialAntinodes(nodeA, nodeB) {
    // "an antinode occurs at any point that is perfectly in line with two antennas of the same frequency - but only when one of the antennas is twice as far away as the other"
    return [
      {x: nodeA.x + (nodeA.x - nodeB.x), y: nodeA.y + (nodeA.y - nodeB.y)},
      {x: nodeB.x + (nodeB.x - nodeA.x), y: nodeB.y + (nodeB.y - nodeA.y)},
    ] // note that these need to be filtered to remove ones that are off-map
  }
  const {
    matrix,
    matrixWidth,
    matrixHeight,
    antennas,
  } = processInput(input)
  const antinodes = Array(matrixHeight).fill(null).map(() => Array(matrixWidth).fill(null).map(() => 0))
  Object.entries(antennas).forEach(([frequency, antennasAtFrequency]) => {
    if (antennasAtFrequency.length < 2) return // need at least 2 nodes
    const antinodesForFrequency = antennasAtFrequency.reduce((acc, elem, index) => {
      if (!antennasAtFrequency[index + 1]) return acc // last antenna in the list
      for (let cursor = index + 1; cursor < antennasAtFrequency.length; cursor++) {
        // O(n*log(n))
        const antinodesOfThisPair = generatePotentialAntinodes(elem, antennasAtFrequency[cursor])
          .filter(({x, y}) => x >= 0 && x < matrixWidth && y >= 0 && y < matrixHeight)
        acc.push(...antinodesOfThisPair)
        antinodesOfThisPair.forEach((antinode) => {
          antinodes[antinode.y][antinode.x] += 1
        })
      }
      return acc
    }, [])
  })
  return antinodes.reduce((totalSum, rowOfAntinodes) => {
    return totalSum + rowOfAntinodes.reduce((rowSum, countOfFrequencies) => {
      if (countOfFrequencies)
        return rowSum + 1 // NOTE not + count, because we only care whether there is an antinode for anyfrequency
      return rowSum
    }, 0)
  }, 0)
}

const delay = ms => new Promise(resolve => setTimeout(resolve, ms))

const quoteUnquotePrecision = 10e12
function fudgeItToAccountForFloatingPointNonsense(n) {
  // e.g. 27.999999999999996 should be 28
  return Math.round(n * quoteUnquotePrecision) / quoteUnquotePrecision
}

function part2(input) {
  const {
    matrix,
    matrixWidth,
    matrixHeight,
    antennas,
  } = processInput(input)
  // console.log('\n\n' + Array(matrixWidth).fill('=').join(''))
  // console.log(matrix.map(l => l.map(n => n === '.' ? ' ' : n).join('')).join('\n'))
  function slope(nodeA, nodeB) { // NOTE oof I hope JS floating-point math doesn't bite me in the ass here
    // y = m*x + b
    // m = rise/run = (y2 - y1)/(x2 - x1)
    // ...note when visualizing this: if positive Y goes down, then this slope will be "backwards" from what you might expect from whether it's positive or negative
    const m = nodeB.x === nodeA.x
      ? null // infinite => vertical line
      : (nodeB.y - nodeA.y) / (nodeB.x - nodeA.x)
    // now solve for b...
    // y = m*x + b
    // y - m*x = b
    const b = nodeA.y - m * nodeA.x
    return {m, b}
  }
  const antinodesPresence = Array(matrixHeight).fill(null).map(() => Array(matrixWidth).fill(null).map(() => ' '))
  Object.entries(antennas).forEach(([frequency, antennasAtFrequency]) => {
    // console.log(frequency, antennasAtFrequency.map(a => `(${a.x},${a.y})`).join(' '))
    // console.log(matrix.map(l => l.map(n => n === frequency ? frequency : ' ').join('')).join('\n'))
    // console.log(Array(matrixWidth).fill('-').join(''))
    antennasAtFrequency.forEach((antennaA, index) => {
      if (!antennasAtFrequency[index + 1]) return // last antenna in the list
      for (let cursor = index + 1; cursor < antennasAtFrequency.length; cursor++) { // O(n*log(n))
        const antennaB = antennasAtFrequency[cursor]
        const {m, b} = slope(antennaA, antennaB)
        if (m === null)
          for (let y = 0; y < matrixHeight; y++)
            antinodesPresence[y][antennaA.x] = frequency
        else
          for (let x = 0; x < matrixWidth; x++) { // NOTE this should be optimized to only search within the map...
            if (m === 0)
              antinodesPresence[antennaA.y][x] = frequency
            else {
              let y = fudgeItToAccountForFloatingPointNonsense(m * x + b)
              if (y >= 0 && y < matrixHeight) {
                if (Math.floor(y) === y)
                  antinodesPresence[y][x] = frequency

              }
            }
          }
      }
    })
    // console.log(antinodesPresence.map(l => l.join('')).join('\n'))
  })
  return antinodesPresence.reduce((totalSum, row) => {
    return totalSum + row.reduce((lineSum, n) => n === ' ' ? lineSum : lineSum + 1, 0)
  }, 0)
}

test('part 1', () => {
  expect(part1(sampleInput)).toEqual(14)
  expect(part1(fullInput)).toEqual(364)
})

test('part 2', () => {
  expect(fudgeItToAccountForFloatingPointNonsense(27.999999999999996)).toEqual(28)
  expect(part2(`
    ....x
    .....
    ..x..
    .....
    .....`)).toEqual(5)
  expect(part2(`
    ......
    .x...x
    ......`)).toEqual(6)
  expect(part2(`
    .v.
    ...
    ...
    .v.`)).toEqual(4)
  expect(part2(`
    T.........
    ...T......
    .T........
    ..........
    ..........
    ..........
    ..........
    ..........
    ..........
    ..........`)).toEqual(9)
  expect(part2(`
    T.........
    ...T......
    .T........
    ..........
    ..........
    ..........
    ......1...
    ..........
    ........10
    ........0.`)).toEqual(20)
  expect(part2(sampleInput)).toEqual(34)
  expect(part2(fullInput)).toBe(1231)
})
