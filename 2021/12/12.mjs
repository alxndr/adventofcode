// have to run using `--stack-size=8192` in order to get through input-c file in NodeJS 17
// ...blows the heap using the full input file

import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input-c.txt')).split(/\n/)

function isUnique(list) {
  return new Set(list).size === list.length
}

function Cave(value) {
  this.name = value
  this.edges = []
  this.isBig = value === value.toUpperCase()
}
const caves = input.reduce((caves, inputLine) => {
  if (!inputLine.length)
    return caves
  const [startpoint, endpoint] = inputLine.split('-')
  const startNode = caves[startpoint] || (caves[startpoint] = new Cave(startpoint))
  const endNode   = caves[endpoint]   || (caves[endpoint]   = new Cave(endpoint))
  startNode.edges.push(endNode)
  endNode.edges.push(startNode)
  return caves
}, {})

function Path(sequence) {
  const lastCave = () => this.sequence.slice(-1)[0]
  this.sequence = sequence
  this.add = (cave) => new Path([...this.sequence, cave])
  this.toString = () => this.sequence.map(cave => cave.name).join(',')
  this.isAtEnd = lastCave().name === caves.end.name
  this.isCaveEligibleToVisit = (cave) => {
    if (cave.name === caves.start.name)
      return false
    if (cave.name === caves.end.name)
      return true
    if (cave.isBig) // "big caves can be visited any number of times"
      return true
    // "a single small cave can be visited at most twice, and the remaining small caves can be visited at most once"
    const smallCavesVisited = this.sequence.filter(c => !c.isBig).map(c => c.name)
    return !smallCavesVisited.includes(cave.name) || isUnique(smallCavesVisited)
  }
  this.findEligibleNextCaves = () => {
    return lastCave().edges.filter(this.isCaveEligibleToVisit)
  }
}

function findPaths(paths, successfulPaths = []) {
  if (!paths.length)
    return successfulPaths
  const [path, ...restPaths] = paths
  if (path.isAtEnd)
    return findPaths(restPaths, [...successfulPaths, path])
  const morePaths = path.findEligibleNextCaves().map(cave => path.add(cave))
  return findPaths([...restPaths, ...morePaths], successfulPaths)
}

const successful = findPaths([new Path([caves.start])])
global.console.log('num successful paths:', successful.length)
// global.console.log(successful.map(p => p.toString()).join('\n'))
// global.console.log('longest:', successful
//   .reduce((longest, path) => {
//     const [firstLongPath] = longest
//     if (!(firstLongPath?.sequence.length) || path.sequence.length > firstLongPath.sequence.length)
//       return [path]
//     if (path.sequence.length === firstLongPath.sequence.length) {
//       return [...longest, path]
//     return longest
//     }
//   }, [])
//   .map(p => p.toString()))
