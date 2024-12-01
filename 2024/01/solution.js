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

function part2(filename) {
}

test('part 2', async () => {
  assert.strictEqual(31, await part2('sample.txt'))
  assert.strictEqual('unknown', await part2('input.txt'))
})
