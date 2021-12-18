import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input.txt')).split(/\n/)

function pointsIntoMatrix(pointsArr) {
  return pointsArr.reduce((matrix, [x, y]) => {
    if (!matrix[y])
      matrix[y] = []
    if (!matrix[y][x])
      matrix[y][x] = true
    return matrix
  }, [])
}

const processedIntoArrays = input.reduce(({pointsArr, folds}, inputLine) => {
  if (!inputLine.length)
    return {pointsArr, folds}
  if (inputLine.includes(',')) {
    return {
      pointsArr: [...pointsArr, inputLine.split(',').map(Number)],
      folds,
    }
  }
  return {
    pointsArr,
    folds: [...folds, inputLine.split(' ')[2].split('=')],
  }
}, {pointsArr: [], folds: []})

function draw(pointsArr) {
  const maxRowLength = Math.max(...pointsArr.map(([x]) => x)) + 1
  global.console.log(Array(maxRowLength).fill('-').join(''))
  global.console.log(pointsIntoMatrix(pointsArr).map(row => {
    let str = ''
    for (let i = 0; i < maxRowLength; i++) {
      str += row[i] ? '#' : ' '
    }
    return str + '|'
  }).join('\n'))
  global.console.log(Array(maxRowLength).fill('-').join(''))
}

const sum = (a, b) =>
  a + b
const numPoints = (pointsArray) =>
  pointsIntoMatrix(pointsArray)
    .map(row => row.filter(Boolean).length)
    .reduce(sum)

function foldArr(pointsArr, [foldDir, axis]) {
  global.console.log('folding...', {foldDir, axis})
  const transformation = (n) => n > axis ? axis - (n - axis) : n
  if (foldDir === 'y') { // horizontal axis, y-values to be modified
    return pointsArr.reduce((foldedPoints, [pX, pY]) => [...foldedPoints, [pX, transformation(pY)]], [])
  }
  // vertical axis; x-values to be modified
  return pointsArr.reduce((foldedPoints, [pX, pY]) => [...foldedPoints, [transformation(pX), pY]], [])
}

const foldedArr = processedIntoArrays.folds.reduce((pointsArr, [foldDir, axis]) => {
  return foldArr(pointsArr, [foldDir, axis])
}, processedIntoArrays.pointsArr)

draw(foldedArr)
