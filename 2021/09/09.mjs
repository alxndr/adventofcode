import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input.txt')).split(/\n/)

const basins = []

function Basin() {
  this.nth = basins.push(this) - 1
  this.points = []
  this.add = ({indexX, indexY}) => {
    this.points.push(`${indexX},${indexY}`)
  }
  this.combineWith = (otherBasin) => {
    global.console.log('combining...', otherBasin.nth, 'into', this.nth)
    this.points.push(...otherBasin.points) // combine points
    basins[basins.indexOf(otherBasin)] = this.nth // remove otherBasin from list of basins, leave a pointer
  }
  this.size = () => this.points.length
}
function findBasin(basinOrNumber = null) {
  if (basinOrNumber === null) return null
  if (basinOrNumber instanceof Basin)
    return basinOrNumber
  return findBasin(basins[basinOrNumber])
}

const taggedMatrix = input.reduce((taggedLines, inputLine, indexY) => {
  if (!(inputLine?.length))
    return taggedLines
  const taggedLine = inputLine.split('').reduce((thisLineTagged, numStr, indexX) => {
    const num = Number(numStr)
    if (num === 9)
      return thisLineTagged.concat({num})
    const basinAbove = findBasin(taggedLines.slice(-1)?.[0]?.[indexX]?.basin)
    const basinLeft = findBasin(thisLineTagged.slice(-1)?.[0]?.basin)
    if (basinAbove && basinLeft && basinAbove !== basinLeft) {
      basinAbove.combineWith(basinLeft) // subsume the left one into the top one
    }
    const basin = basinAbove || basinLeft || new Basin()
    basin.add({indexX, indexY})
    return thisLineTagged.concat({num, basin: basin.nth})
  }, [])
  return taggedLines.concat([taggedLine])
}, [])

global.console.log(input.join('\n').replace(/9/g, ' '), '\n')
global.console.log(taggedMatrix.map(line => line.map(({basin}) => findBasin(basin)?.nth.toString() || ' ').join('')).join('\n'), '\n')

const sizes = (basins.filter(b => b.points).map(b => b.size()))
global.console.log({sizes})

function largestAmong(arr) { return Math.max(...arr) }
function largestNAmong(n, arr, results = []) { 
  if (n === 0)
    return results
  const largest1 = largestAmong(arr)
  arr.splice(arr.indexOf(largest1), 1) // modifies `arr`
  return largestNAmong(n - 1, arr, results.concat(largest1))
}

global.console.log('largest 3, summed...', largestNAmong(3, sizes).reduce((a, b) => a * b))
