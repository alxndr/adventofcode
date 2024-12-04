// note that the input is not necessarily square...

const inputToMatrix = (input) => {
  return input.trim().split(/\r?\n/)
}

const DIRS = {
  N : [{       y: -1}, {       y: -2}, {       y: -3}],
  NE: [{x:  1, y: -1}, {x:  2, y: -2}, {x:  3, y: -3}],
  E : [{x:  1       }, {x:  2       }, {x:  3       }],
  SE: [{x:  1, y:  1}, {x:  2, y:  2}, {x:  3, y:  3}],
  S : [{       y:  1}, {       y:  2}, {       y:  3}],
  SW: [{x: -1, y:  1}, {x: -2, y:  2}, {x: -3, y:  3}],
  W : [{x: -1       }, {x: -2       }, {x: -3       }],
  NW: [{x: -1, y: -1}, {x: -2, y: -2}, {x: -3, y: -3}],
}
// TODO optimization: search for backwards string to avoid going all the way to the end

const doTheThing = (matrix) => {
  let found = 0
  const height = matrix.length
  const width = matrix[0].length
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      if (!(matrix[y]))    continue
      if (!(matrix[y][x])) continue
      if (matrix[y][x] === 'X' ) {
        for (const [dir, moves] of Object.entries(DIRS)) {
          const y1 = y + (moves[0]?.['y'] ?? 0)
          if (!matrix[y1])                           continue
          const x1 = x + (moves[0]?.['x'] ?? 0)
          if (!matrix[y1][x1])                       continue
          const y2 = y + (moves[1]?.['y'] ?? 0)
          if (!matrix[y2])                           continue
          const x2 = x + (moves[1]?.['x'] ?? 0)
          if (!matrix[y2][x2])                       continue
          const y3 = y + (moves[2]?.['y'] ?? 0)
          if (!matrix[y3])                           continue
          const x3 = x + (moves[2]?.['x'] ?? 0)
          if (!matrix[y3][x3])                       continue
          if (matrix[y1][x1] === 'M'
           && matrix[y2][x2] === 'A'
           && matrix[y3][x3] === 'S') {
              found += 1
          }
        }
      }
    }
  }
  return found
}

const sample1 = `
..X...
.SAMX.
.A..A.
XMAS.S
.X....`
console.log('sample 1:', doTheThing(inputToMatrix(sample1))) // answer to this is 4

const sample2 = `
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
`
console.log('sample 2:', doTheThing(inputToMatrix(sample2))) // answer to this is 18

import fs from 'fs'
const fullInput = fs.readFileSync('./input.txt', 'utf8')

console.log('full input:', doTheThing(inputToMatrix(fullInput)))
