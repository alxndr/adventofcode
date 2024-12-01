import {open} from 'node:fs/promises'
import assert from 'node:assert'

const fh = await open('./input.txt')

const leftList = []
const rightList = []

for await (const line of fh.readLines()) {
  const [left, right] = line.split(/\s+/)
  leftList.push(Number(left))
  rightList.push(Number(right))
  // optimization: keep sorted as we insert...
}

assert.equal(leftList.length, rightList.length,
  'lists are not the same length!!'
)

leftList.sort()
rightList.sort()

let sumOfDifferences = 0
for (let i = 0; i < leftList.length; i++) {
  const left = leftList[i]
  const right = rightList[i]
  sumOfDifferences += Math.abs(left - right)
}

console.log({sumOfDifferences})
