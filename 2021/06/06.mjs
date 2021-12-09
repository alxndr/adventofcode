import {readFile} from '../helpers.file.mjs'

const numDays = 190 // JS Heap running out of memory a little above this

function stepper(n) {
  return n ? --n : [6, 8]
}
function day(fishes) {
  return fishes.flatMap(stepper)
}

function days(n, fishes, memo) { // recursive
  if (!n) {
    return memo
  }
  const family = day(fishes)
  if (n <= 9) // only need the last chunk of values that will be calculated...
    memo[numDays - (n - 1)] = family.length
  return days(n - 1, family, memo)
}

const memo = days(numDays, [0], [])
global.console.log(memo.map((n, index) => `${index}: ${n}`))

const input = (await readFile('./input-short.txt')).split(/\n/)[0].split(',')

function findFamSize(initTimer, days) {
  return initTimer
    ? memo[numDays - initTimer]
    : memo[numDays]
}
const totalPopulation = input.reduce((sum, initTimer) => sum + findFamSize(initTimer, numDays), 0)
global.console.log({input, numDays, totalPopulation})
