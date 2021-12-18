// have to run using `--stack-size=4096` in order to get through the input file in NodeJS 17

import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input.txt')).split(/\n/)

// "Your goal is to find the number of distinct paths that start at start, end at end, and don't visit small caves more than once."

function Cave(value) {
  this.name = value
  this.edges = []
  // "all paths you find should visit small caves at most once, and can visit big caves any number of times"
  this.isBig = value === value.toUpperCase()
  this.visited = false
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
  this.sequence = [...sequence] // of caves
  this.add = (cave) => new Path([...this.sequence, {...cave, visited: true}])
  this.lastCave = () => this.sequence.slice(-1)[0]
  this.toString = () => this.sequence.map(cave => cave.name).join(',')
  this.isCaveEligibleToVisit = (cave) => {
    if (cave.name === caves.start.name)
      return false
    if (cave.isBig)
      return true
    return !this.sequence.find(c => c.name === cave.name)
  }
  this.findEligibleNextCaves = () => {
    return this.lastCave().edges.filter(this.isCaveEligibleToVisit)
  }
}

function findPaths(paths, successfulPaths = []) {
  if (!paths.length)
    return successfulPaths
  const [path, ...restPaths] = paths
  const cave = path.lastCave()
  if (cave.name === caves.end.name)
    return findPaths(restPaths, [...successfulPaths, path])
  return findPaths([...restPaths, ...path.findEligibleNextCaves().map(cave => path.add(cave)),], successfulPaths)
}

const successful = findPaths([new Path([caves.start])])
global.console.log('num successful paths:', successful.length)
global.console.log('longest:', successful
  .reduce((longest, path) => {
    const [firstLongPath] = longest
    if (!(firstLongPath?.sequence.length) || path.sequence.length > firstLongPath.sequence.length)
      return [path]
    if (path.sequence.length === firstLongPath.sequence.length) {
      return [...longest, path]
    return longest
    }
  }, [])
  .map(p => p.toString()))
