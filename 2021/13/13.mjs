import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input-a.txt')).split(/\n/)

const processed = input.reduce(({points, folds}, inputLine) => {
  if (!inputLine.length)
    return {points, folds}
  if (inputLine.includes(',')) {
    return {
      points: [...points, inputLine.split(',').map(Number)],
      folds,
    }
  }
  return {
    points,
    folds: [...folds, inputLine.split(' ')[2].split('=')],
  }
}, {points: [], folds: []})

const folded = processed.folds.reduce((points, [foldDir, axis]) => {
  drawPoints(points)
  const transformation = (n) => n > axis ? axis - (n - axis) : n
  if (foldDir === 'y') { // horizontal axis, y-values to be modified
    return points.reduce((foldedPoints, [pX, pY]) => [...foldedPoints, [pX, transformation(pY)]], [])
  }
  // vertical axis; x-values to be modified
  return points.reduce((foldedPoints, [pX, pY]) => [...foldedPoints, [transformation(pX), pY]], [])
}, processed.points)
global.console.log('\n')

function drawPoints(points) {
  const maxRowLength = Math.max(...points.map(([x]) => x)) + 1
  global.console.log(points.reduce((matrix, [x, y]) => {
    if (!matrix[x])
      matrix[x] = []
    if (!matrix[x][y])
      matrix[x][y] = true
    return matrix
  }, []).map(row => {
    let str = ''
    for (let i = 0; i < maxRowLength; i++) {
      str += row[i] ? '#' : ' '
    }
    return str
  }).join('\n'))
}

drawPoints(folded)
