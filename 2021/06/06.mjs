import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input.txt')).split(/\n/)[0].split(',')

// what if we calculate days to numDays/2
// then go through the `family` and sum the population for each member of the fam after a second period of numDays/2 days

const numDays = 512

function stepper(n) {
  return n ? --n : [6, 8]
}

function growFamilyMemoizedRecursing({day, end, family, memo}) {
  if (day > end)
    return [family, memo]
  const nextGeneration = family.flatMap(stepper)
  memo[day] = nextGeneration
  return growFamilyMemoizedRecursing({day: ++day, end, family: nextGeneration, memo})
}
function growFamilyMemoized(days) {
  return growFamilyMemoizedRecursing({day: 1, end: days, family: [0], memo: []})
}
let start = Date.now()
const offset = numDays % 2
const halfTheTimePeriod = Math.floor(numDays/2) + offset
const [family0, memo0] = growFamilyMemoized(halfTheTimePeriod) // this is the family tree of a single Fish0
// global.console.log(`after ${halfTheTimePeriod} days, single Fish0 has ${family0.length} descendants`)
// global.console.log(memo0.filter(i => i >= halfTheTimePeriod - 8).map((m, i) => `#${i}: ${m}`).join('\n'))
// const summedPopulation = family
//   .map(gen25memberTimer => {
//     const index = (halfTheTimePeriod - offset) - (gen25memberTimer)
//     // global.console.log({fishTimer: gen25memberTimer, index, descendants: memo0[index]?.length})
//     return memo0[index].length
//   }).reduce((a, b) => a + b, offset ? 0 : 0)
// global.console.log({summedPopulation})
const halfTimePeriodFamily = input.reduce((descendants, initTimer) => {
  const index = halfTheTimePeriod - offset - initTimer
  // global.console.log({initTimer, index, descendants: memo0[index]})
  return descendants.concat(memo0[index])
}, [])
const descendantPopulation = halfTimePeriodFamily.reduce((sum, initTimer) => {
  const index = halfTheTimePeriod - offset - initTimer
  // global.console.log({initTimer, index, descendants: memo0[index]})
  return sum + memo0[index].length
}, 0)
global.console.log({seconds: (Date.now() - start)/1000, inputSize: input.length, numDays, descendants: descendantPopulation})
