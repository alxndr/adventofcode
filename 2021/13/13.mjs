import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input-a.txt')).split(/\n/)

function pointsIntoMatrix(points) {
  return points.reduce((matrix, [x, y]) => {
    if (!matrix[y])
      matrix[y] = []
    if (!matrix[y][x])
      matrix[y][x] = true
    return matrix
  }, [])
}

const processedIntoArrays = input.reduce(({points, folds}, inputLine) => {
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

const sum = (a, b) =>
  a + b
const numPoints = (pointsArray) =>
  pointsIntoMatrix(pointsArray)
    .map(row => row.filter(Boolean).length)
    .reduce(sum)

drawPoints(processedIntoArrays.points)
global.console.log('number of points...', numPoints(processedIntoArrays.points))

function fold(pointsArr, foldDir, axis) {
  global.console.log('folding...', {foldDir, axis})
  const transformation = (n) => n > axis ? axis - (n - axis) : n
  if (foldDir === 'y') { // horizontal axis, y-values to be modified
    return pointsArr.reduce((foldedPoints, [pX, pY]) => [...foldedPoints, [pX, transformation(pY)]], [])
  }
  // vertical axis; x-values to be modified
  return pointsArr.reduce((foldedPoints, [pX, pY]) => [...foldedPoints, [transformation(pX), pY]], [])
}

const foldedArr = processedIntoArrays.folds.reduce((pointsArr, [foldDir, axis]) => {
  const foldedArr = fold(pointsArr, foldDir, axis)
  drawPoints(foldedArr)
  return foldedArr
}, processedIntoArrays.points)

function drawPoints(points) {
  const maxRowLength = Math.max(...points.map(([x]) => x)) + 1
  global.console.log(Array(maxRowLength).fill('-').join(''))
  global.console.log(pointsIntoMatrix(points).map(row => {
    let str = ''
    for (let i = 0; i < maxRowLength; i++) {
      str += row[i] ? '#' : ' '
    }
    return str + '|'
  }).join('\n'))
  global.console.log(Array(maxRowLength).fill('-').join(''))
}

// drawPoints(foldedArr)
