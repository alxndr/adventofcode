import {readFile} from '../helpers.file.mjs'
const inputLines = (await readFile('./input.txt')).split(/\n/)

// first line of inputLines is the automaton input
// then a newline
// then a chunk of transformation rules... which have '->' in em
const [template, _, ...transformationRules] = inputLines

const mapping = transformationRules.reduce((mapping, inputLine) => {
  if (!inputLine.length) return mapping
  const [startingSequence, newInfix] = inputLine.split(' -> ')
  return {...mapping, [startingSequence]: newInfix}
}, {})

const obj = template.split('').reduce((data, letter, index, arr) => {
  if (data.letterCounts[letter]) { // count occurrences of letters
    data.letterCounts[letter] += 1
  } else {
    data.letterCounts[letter] = 1
  }
  if (arr[index + 1]) {
    const pair = `${letter}${arr[index + 1]}`
    if (!data.pairs[pair]) data.pairs[pair] = 0
    data.pairs[pair] += 1
  }
  return data
}, {letterCounts: {}, pairs: {}})

function step(obj) {
  // obj has letterCounts and pairs
  const {letterCounts, pairs} = obj
  const newPairsDict = Object.entries(pairs).reduce((dict, [pair, count]) => {
    const infix = mapping[pair]
    if (infix) {
      if (letterCounts[infix]) letterCounts[infix] += count
      else                     letterCounts[infix] = count
      const [firstLetter, secondLetter] = pair.split('')
      const firstNewPair = `${firstLetter}${infix}`
      const secondNewPair = `${infix}${secondLetter}`
      if (dict[firstNewPair]) dict[firstNewPair] += count
      else                    dict[firstNewPair] = count
      if (dict[secondNewPair]) dict[secondNewPair] += count
      else                     dict[secondNewPair] = count
    } else {
      if (dict[pair]) dict[pair] += count
      else            dict[pair] = count
    }
    return dict
  }, {})
  return {
    letterCounts,
    pairs: newPairsDict,
  }
}

function multipleSteps(obj, n) { // recursive
  logPairs(obj)
  if (n)
    return multipleSteps(step(obj), n - 1)
  return obj
}

const sum = (a, b) => a + b

function logPairs({letterCounts, pairs}) {
  global.console.log(Object.entries(pairs).map(([pair, count]) => `${pair}:${count}`).join('  '))
  global.console.log('length: ', Object.values(pairs).reduce(sum) + 1)
  const {
    mostCommonCount,
    mostCommonLetter,
    leastCommonCount,
    leastCommonLetter,
  } = Object.entries(letterCounts).reduce((result, [letter, count]) => {
    if (count > result.mostCommonCount) {
      result.mostCommonCount = count
      result.mostCommonLetter = letter
    }
    if (count < result.leastCommonCount) {
      result.leastCommonCount = count
      result.leastCommonLetter = letter
    }
    return result
  }, {mostCommonCount: 0, leastCommonCount: Infinity})
  global.console.log({mostCommonLetter, mostCommonCount, leastCommonLetter, leastCommonCount})
  global.console.log('difference:', mostCommonCount - leastCommonCount)
}

multipleSteps(obj, 40)
