import {open} from 'node:fs/promises'
import assert from 'node:assert'
import test from 'node:test'

async function part1(filename) {
  const fh = await open(filename)

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

  return sumOfDifferences
}

test('part 1', async () => {
  assert.strictEqual(11, await part1('sample.txt'))
  assert.strictEqual(2164381, await part1('input.txt'))
})

async function part2(filename) {
  const lhs = {}
  const rhs = {}
  for await (const line of (await open(filename)).readLines()) {
    const [left, right] = line.split(/\s+/)
    if (lhs.hasOwnProperty(left))
      lhs[left] += 1
    else
      lhs[left] = 1
    if (rhs.hasOwnProperty(right))
      rhs[right] += 1
    else
      rhs[right] = 1
  }
  let score = 0
  for (const [n, count] of Object.entries(lhs)) {
    if (rhs.hasOwnProperty(n)) {
      score += Number(n) * rhs[n] * count
    }
  }
  return score
}

test('part 2', async () => {
  assert.strictEqual(31, await part2('sample.txt'))
  assert.strictEqual(20719933, await part2('input.txt'))
})
