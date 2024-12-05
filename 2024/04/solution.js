import fs from 'fs'

const inputToMatrix = (input) => {
  return input.split(/\r?\n/).map(s => s.trim()).filter(s => s.length)
}

const part1 = () => {
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
  console.log('part 1....\n')
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

const part2 = () => {
  console.log('\n\npart 2....\n')
  const solve = (matrix) => {
    const height = matrix.length
    const width = matrix[0].length
    const charNW = ({x,y}) => matrix[y-1][x-1]
    const charNE = ({x,y}) => matrix[y-1][x+1]
    const charSE = ({x,y}) => matrix[y+1][x+1]
    const charSW = ({x,y}) => matrix[y+1][x-1]
    const isAnX = ({x,y}) => {
      if (matrix[y][x] != 'A')
        return false
      if (y === 0 || y === height - 1 || x === 0 || x === width - 1)
        return false
      if ( ((charNW({x,y}) === 'M' && charSE({x,y}) === 'S') || (charSE({x,y}) === 'M' && charNW({x,y}) === 'S'))
        && ((charNE({x,y}) === 'M' && charSW({x,y}) === 'S') || (charSW({x,y}) === 'M' && charNE({x,y}) === 'S'))
      )
        return true
      return false
    }
    let count = 0
    for (let y = 1; y < height - 1; y++)
      for (let x = 1; x < width - 1; x++)
        if (isAnX({x,y}))
          count += 1
    return count
  }

  const sample1 = `
    M.S
    SAM
    M.S
  `
  console.log('sample 1:', solve(inputToMatrix(sample1))) // answer to this is 1

  const sample2 = `
    .M.S......
    ..A..MSMS.
    .M.S.MAA..
    ..A.ASMSM.
    .M.S.M....
    ......A...
    S.S.S.SSS.
    .A.A.A.A..
    M.M.M.M.M.
    .......... `
  console.log('sample 2:', solve(inputToMatrix(sample2))) // answer to this is 9

  const fullInput = fs.readFileSync('./input.txt', 'utf8')
  console.log('full input:', solve(inputToMatrix(fullInput)))
}

part2()
