import {readFile} from '../helpers.file.mjs'

const data = (await readFile('./input.txt')).split(/\n/)

/* data structure... array of arrays of integers
 * can grow as we see bigger numbers
 * [
 *   [ #, #, ... ],
 *   ...,
 * ]
 */

function zeroes(howMany) {
  return Array(howMany).fill(null).map(_ => 0)
}

function rangeIntegersInclusive(a, b) {
  const howMany = Math.abs(a - b) + 1
  return Array(howMany).fill(null).map((_, i) => (a > b ? b : a) + i)
}

function sum(a, b) {
  return a + b
}

function coordinatesShareDimension({aX, aY, bX, bY}) {
  return aX === bX || aY === bY
}
function coordinatesAreSquare({aX, aY, bX, bY}) {
  return aX === bY && aY === bX
}

function Field() {
  // size of field will grow as segments are added
  const rows = [[0]] // corresponds to X direction, sub-array elements vary in Y direction
  function addSegment({aX, aY, bX, bY}) {
    if (coordinatesShareDimension({aX, aY, bX, bY}) || coordinatesAreSquare({aX, aY, bX, bY})) {
      global.console.log('adding...', `{${aX},${aY}:${bX},${bY}}`)
      growField({aX, aY, bX, bY})
      const colRange = rangeIntegersInclusive(aX, bX)
      const rowRange = rangeIntegersInclusive(aY, bY)
      if (colRange.length > 1 && rowRange.length > 1) {
        console.assert(colRange.length === rowRange.length, 'ruh roh............')
        // diagonal
        colRange.forEach((_, index) => {;
          rows[rowRange[0]+index][colRange[0]+index] += 1
        })
      } else {
        // only one of them beter be 1-length
        rowRange.forEach(row => {
          colRange.forEach(col => {
            rows[row][col] += 1
          })
        })
      }
    }
  }
  function growField({aX, aY, bX, bY}) {
    const maxX = Math.max(aX, bX),
      maxY = Math.max(aY, bY)
    if (!rows[0].hasOwnProperty(maxX)) {
      const howMany = maxX - numCols() + 1
      global.console.log('growing cols by', howMany)
      rows.forEach(row => row.push(...zeroes(howMany))) 
    }
    if (!rows.hasOwnProperty(maxY)) {
      const howMany = maxY - numRows() + 1
      global.console.log('growing rows by', howMany)
      rows.push(...Array(howMany).fill(null).map(_ => zeroes(numCols()))) // beware how Array.fill works
    }
  }
  function numCols() { return rows[0].length }
  function numRows() { return rows.length }
  return {
    addSegment,
    get asString() { return rows.map(row => row.map(val => val || '.').join('')).join('\n') },
    get numOverlapping() { return rows.map(row=>row.filter(value=>value>=2).length).reduce(sum, 0) },
  }
}

const field = data.reduce((f, line) => {
  if (!line?.length) return f
  const [pointA, pointB] = line.split(' -> ')
  const [aX, aY] = pointA.split(',').map(Number)
  const [bX, bY] = pointB.split(',').map(Number)
  f.addSegment({aX, aY, bX, bY})
  // global.console.log(f)
  return f
}, new Field())

global.console.log(field.asString)
global.console.log('overlapping points', field.numOverlapping)
