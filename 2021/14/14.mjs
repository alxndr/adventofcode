// run with `--stack-size=2048` to get through ten steps of full input file

import {readFile} from '../helpers.file.mjs'
const inputLines = (await readFile('./input.txt')).split(/\n/)

// first line of inputLines is the automaton input
// then a newline
// then a chunk of transformation rules... which have '->' in em

const mapping = inputLines.slice(2).reduce((mapping, inputLine) => {
  if (!inputLine.length) return mapping
  const [startingSequence, newInfix] = inputLine.split(' -> ')
  return {...mapping, [startingSequence]: newInfix}
}, {})

const alphabet = Object.entries(mapping).reduce((alphabet, [pair, infix]) => {
  [...pair.split(''), infix].forEach(letter => alphabet[letter] || (alphabet[letter] = true))
  return alphabet
}, {})

function allPairs(string = '', foundPairs = []) {
  if (string.length < 2)
    return foundPairs
  return allPairs(string.slice(1), [...foundPairs, string.slice(0, 2)])
}
function Automaton(input) {
  const template = input
  let value = template
  const possibleLetters = value.split('').reduce((chrs, chr) => {
    if (!chrs[chr])
      chrs[chr] = true 
    return chrs
  }, alphabet)
  let steps = 0
  this.step = () => {
    ++steps
    value = allPairs(value)
      .reduce((sequence, pair) => `${sequence}${pair[0]}${mapping[pair] || ''}`, '')
      + value.slice(-1)
  }
  this.size = () => value.length
  this.occurrencesOf = (chr) => value.match(new RegExp(chr, 'g')).length
  this.steps = () => Number(steps)
  this.stats = () => {
    global.console.log('Automaton, template:', template)
    global.console.log('alphabet:', Object.keys(possibleLetters).sort().join(''))
    global.console.log('steps:', this.steps(), 'size:', this.size())
    const occurrencesSorted = Object.keys(possibleLetters).map(letter => ({letter, num: this.occurrencesOf(letter)})).sort((a, b) => a.num - b.num)
    const leastCommon = occurrencesSorted[0]
    const mostCommon = occurrencesSorted.slice(-1)[0]
    global.console.log('most common:', mostCommon.letter, mostCommon.num)
    global.console.log('least common:', leastCommon.letter, leastCommon.num)
    global.console.log('difference:', mostCommon.num - leastCommon.num)
  }
}

const automaton = new Automaton(inputLines[0])

automaton.step()
automaton.step()
automaton.step()
automaton.step()
automaton.step()
automaton.step()
automaton.step()
automaton.step()
automaton.step()
automaton.step()

automaton.stats()
