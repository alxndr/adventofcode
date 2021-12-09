import {readFile} from '../helpers.file.mjs'

const numDays = 196 // JS Heap running out of memory above 196

function stepper(n) {
  return n ? --n : [6, 8]
}
let memo = []
function days(n, fishes) { // recursive; mutates `memo`
  if (!n) {
    return memo
  }
  const family = fishes.flatMap(stepper)
  if (n <= 9) // only need the last chunk of values that will be calculated...
    memo[numDays - (n - 1)] = family.length
  return days(n - 1, family)
}

days(numDays, [0])
global.console.log(memo.map((n, index) => `${index}: ${n}`))

const input = (await readFile('./input-short.txt')).split(/\n/)[0].split(',')

const totalPopulation = input.reduce((sum, initTimer) => sum + memo[numDays - initTimer], 0)
global.console.log({inputSize: input.length, numDays, totalPopulation})
