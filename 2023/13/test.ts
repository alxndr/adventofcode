import {describe, it} from 'node:test'
import {deepEqual, ok} from 'node:assert'

import {sample, full} from './input.ts'
import {
  separateFields,
  findConsecutiveMatchingRows,
  isMatchingRowsRecursive,
  lookForReflectionRow,
  solvePart1,
  solvePart2,
} from './solution.ts'

console.log('\n\n\n\n')

function PENDING(reason=true) {
  return {skip: reason}
}

describe('separateFields', () => {
  it('rewraps an array to be nested where there are 0-length elements', () => {
    deepEqual(
      separateFields(['a', '', 'b']),
      [['a'], ['b']])
  })
})

describe('findConsecutiveMatchingRows', () => {
  it('returns index 𝒊 where arr[] == arr[+1]', () => {
    deepEqual( findConsecutiveMatchingRows([123, 234, 345, 345, 234]), 2)
    deepEqual( findConsecutiveMatchingRows([123, 234, 345, 234]), -1)
  })
})

describe('isMatchingRowsRecursive', () => {
  it('basic truthy', () => {
    deepEqual(
      isMatchingRowsRecursive(0, 0, [1234]),
      true
    )
  })
  it('bigger truthy', () => {
    deepEqual(
      isMatchingRowsRecursive(2, 3, ['abc', 'def', 'ghi', 'ghi', 'def']),
      true
    )
  })
  it('bigger falsy', () => {
    deepEqual(
      isMatchingRowsRecursive(1, 3, ['abc', 'def', 'ghi', 'ghi', 'def']),
      false
    )
  })
  it('big truthy', () => {
    deepEqual(
      isMatchingRowsRecursive(2, 3, ['abc', 'def', 'ghi', 'ghi', 'def', 'abc', 'xyz', 'uvw']),
      true
    )
  })
})

describe('lookForReflection', () => {
  it('simple truthy', () => {
    deepEqual(
      lookForReflectionRow(['123', 'abc', 'abc']),
      1
    )
  })
  it('simple falsy', () => {
    deepEqual(
      lookForReflectionRow(['abc', '123', 'do re mi']),
      false
    )
  })
  it('trickier truthy', () => {
    deepEqual(
      lookForReflectionRow([
        'one two three',
        'abc',
        'abc',
        'do re mi',
        'foo',
        'foo',
        'do re mi',
        'bar',
        'baz', // here is the first full reflection
        'baz',
        'bar',
        'do re mi',
        'foo', // here is another one though
        'foo',
        'do re mi'
      ]),
      8
    )
  })
  it('pathological??', PENDING('that was not real'), () => {
    const m = ``.split('\n')
    deepEqual(
      lookForReflectionRow(m),
      8
    )
  })
})

describe('solvePart1', () => {
  it('with sample input', async () => {
    deepEqual(
      solvePart1(await sample()),
      405
    )
  })
  it('with full input', async () => {
    const solution = solvePart1(await full()) 
    ok(
      solution > 32889,
      'needs to be above 32889...'
    );
    deepEqual(
      solution,
      33780,
    )
  })
})

describe('solvePart2', PENDING(), () => {
  it('with sample input', async () => {
    deepEqual(
      solvePart1(await sample()),
      'unknown'
    )
  })
  it('with full input', PENDING(), async () => {
    deepEqual(
      solvePart1(await full()),
      'unknown'
    )
  })
})
