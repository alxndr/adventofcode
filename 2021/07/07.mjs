import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input.txt')).split(/\n/)[0].split(',').map(Number)

const sum = input.reduce((a,b) => a + b)
global.console.log({length: input.length})

function totalStepCost(steps) {
  return steps * (steps + 1) / 2
}
function distanceFrom(n, list) {
  return list.reduce((sum, num) => sum + totalStepCost(Math.abs(num - n)), 0)
}
const memo = []
for (let i = 0; i <= input.length; i++) {
  memo[i] = distanceFrom(i, input)
}
const min = Math.min(...memo)
global.console.log({min})
const index = memo.indexOf(min)
global.console.log({index})
