import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input.txt')).split(/\n/)

// "A corrupted line is one where a chunk closes with the wrong character"

const CORRUPTED = 'CORRUPTED'

function isOpener(chr) {
  switch (chr) {
    case '(':
    case '[':
    case '{':
    case '<':
      return true
    default:
      return false
  }
}
function isCloser(chr) {
  switch (chr) {
    case ')':
    case ']':
    case '}':
    case '>':
      return true
    default:
      return false
  }
}
function isMatched(a, b) {
  return (a === '(' && b === ')')
    || (a === '[' && b === ']')
    || (a === '{' && b === '}')
    || (a === '<' && b === '>')
}

function pointsFor(chr) {
  switch (chr) {
    case ')': return 3
    case ']': return 57
    case '}': return 1197
    case '>': return 25137
  }
}

function Corruption(stack, chr) {
  global.console.log(`Corrupted entry... expected match for ${stack.slice(-1)?.[0]} but got ${chr}`)
  this.points = pointsFor(chr)
}

const processed = input.map((inputLine) => {
  const parseResult = inputLine.split('').reduce((stack, chr) => {
    if (stack instanceof Corruption) return stack
    if (isOpener(chr)) {
      stack.push(chr)
      return stack
    }
    if (isCloser(chr) && isMatched(stack.slice(-1)[0], chr)) {
      stack.pop()
      return stack
    }
    // global.console.log('ruh roh', chr)
    return new Corruption(stack, chr)
  }, [])
  return parseResult
})
// global.console.log(processed)
global.console.log('score',
  processed
  .filter(p => p instanceof Corruption)
  .map(corruptedInfo => corruptedInfo.points)
  .reduce((a, b) => a + b))
