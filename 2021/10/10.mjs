import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input.txt')).split(/\n/)

// "A corrupted line is one where a chunk closes with the wrong character"

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

function syntaxPointsFor(chr) {
  switch (chr) {
    case ')': return 3
    case ']': return 57
    case '}': return 1197
    case '>': return 25137
  }
}

function Corruption(stack, chr) {
  global.console.log(`Corrupted entry... expected match for ${stack.slice(-1)?.[0]} but got ${chr}`)
  this.points = syntaxPointsFor(chr)
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
    return new Corruption(stack, chr)
  }, [])
  return parseResult
})

function autocompletePointsForChar(chr) {
  switch (chr) {
    case '(': return 1
    case '[': return 2
    case '{': return 3
    case '<': return 4
    default: return 0
  }
}
function autocompleteScoreForArray(arr) {
  return arr.reduce((score, chr) => {
    return score * 5 + autocompletePointsForChar(chr)
  }, 0)
}

const incomplete = processed.filter(p => !(p instanceof Corruption))
global.console.log('incomplete...', incomplete)
const autocompleteScores = incomplete.map(i => autocompleteScoreForArray(i.reverse()))
global.console.log('each score...', autocompleteScores)
global.console.log('midpoint autocomplete score...', autocompleteScores.sort((a, b) => a - b)[Math.floor(autocompleteScores.length / 2)])
