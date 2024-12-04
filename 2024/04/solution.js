import fs from 'fs'

const inputToMatrix = (input) => {
  return input.split(/\r?\n/).map(s => s.trim())
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

const part1 = () => {
  const solve = (matrix) => {
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
  console.log('sample 1:', solve(inputToMatrix(sample1))) // answer to this is 4

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
  console.log('sample 2:', solve(inputToMatrix(sample2))) // answer to this is 18

  const fullInput = fs.readFileSync('./input.txt', 'utf8')

  console.log('full input:', solve(inputToMatrix(fullInput)))
}

part1()
