import {describe, it} from 'node:test'
import assert from 'node:assert'

import {sample} from './input.ts'
import {part1, Map} from './solution.ts'

console.log('\n2023 day 17 testing...\n');

describe.skip('input', () => {
  describe('sample', () => {
    it('is an array', () => {
      assert.deepEqual(Array.isArray(sample), true)
    })
    it('is full of strings', () => {
      assert.deepEqual(typeof sample[0], 'string')
    })
  })
  describe.skip('full')
})

describe.skip('Map', () => {
  describe('grid', () => {
    it('is an array', () => {
      assert.deepEqual(Array.isArray(new Map(sample).grid), true)
    })
    it('maintains width', () => {
      assert.deepEqual(new Map(['123', '456']).width, 3)
    })
    it('maintains height', () => {
      assert.deepEqual(new Map(['123', '456']).height, 2)
    })
  })
  describe('.at()', () => {
    it('returns a number according to the Coordinate', () => {
      const map = new Map(sample)
      assert.deepEqual(map.at({x:1, y: 0}), 4)
      assert.deepEqual(map.at({x:6, y:10}), 6)
    })
  })
})

describe('part 1', () => {
  describe('sample input', () => {
    it('minimum heat loss is 102', () => {
      assert.deepEqual(part1(sample), 102)
    })
  })
  describe.skip('full input', () => {
    it('minimum heat loss is 102', () => {
      assert.deepEqual(part1(sample), 102)
    })
  })
})

describe.skip('part 2', () => {
  describe('sample', () => {
    it('is a placeholder', () => {
      assert.deepEqual(
        'foo',
        'bar'
      )
    })
  })
})

