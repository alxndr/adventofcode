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

function generatePotentialAntinodes(nodeA, nodeB) {
  // "an antinode occurs at any point that is perfectly in line with two antennas of the same frequency - but only when one of the antennas is twice as far away as the other"
  return [
    {x: nodeA.x + (nodeA.x - nodeB.x), y: nodeA.y + (nodeA.y - nodeB.y)},
    {x: nodeB.x + (nodeB.x - nodeA.x), y: nodeB.y + (nodeB.y - nodeA.y)},
  ] // note that these need to be filtered to remove ones that are off-map
}

function part1(input) {
  const {
    matrix,
    matrixWidth,
    matrixHeight,
    antennas,
  } = processInput(input)
  const antinodes = Array(matrixHeight).fill(null).map(() => Array(matrixWidth).fill(null).map(() => 0))
  let antinodesCount = 0
  Object.entries(antennas).forEach(([frequency, antennasAtFrequency]) => {
    if (antennasAtFrequency.length < 2) return // need at least 2 nodes
    const antinodesForFrequency = antennasAtFrequency.reduce((acc, elem, index) => {
      if (!antennasAtFrequency[index + 1]) return acc // last antenna in the last
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
    // console.log(`antinodes @ freq:${frequency}`, antinodesForFrequency)
  })
  console.log(antinodes.map(line => line.join('')).join('\n'))
  return antinodes.reduce((totalSum, rowOfAntinodes) => {
    return totalSum + rowOfAntinodes.reduce((rowSum, countOfFrequencies) => {
      if (countOfFrequencies)
        return rowSum + 1 // NOTE not + count, because we only care whether there is an antinode for anyfrequency
      return rowSum
    }, 0)
  }, 0)
}

test('part 1', () => {
  expect(part1(sampleInput)).toEqual(14)
  expect(part1(fullInput)).toEqual(14)
})
