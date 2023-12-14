import {describe, it} from 'node:test'
import assert from 'node:assert'

import {
  inputSample,
  dragRocks,
  magnetize,
  calculateLoad,
  solvePart1,
  rotatePart2,
  solvePart2,
  inputFull,
  DIRS
} from './solution.mjs'

console.log('\n\n\n\n')

describe('inputSample', (t) => {
  it('is the right type', () => {
    assert.strictEqual(typeof inputSample, 'object')
    assert.strictEqual(typeof inputSample[0], 'string')
  })
})

describe('magnetize HOF', () => {
  it('works with most basic input', () => {
    assert.deepEqual(magnetize(DIRS.L)(''), '');
    assert.deepEqual(magnetize(DIRS.R)('#'), '#');
    assert.deepEqual(magnetize(DIRS.L)('.'), '.');
    assert.deepEqual(magnetize(DIRS.R)('O'), 'O');
  })
  it('shifts round rocks "O" to the left across land "." stopping at square rocks "#" ', () => {
    assert.deepEqual(magnetize(DIRS.L)('..O'), 'O..')
    assert.deepEqual(magnetize(DIRS.L)('.#.O'), '.#O.')
  })
})

describe('dragRocks', () => {
  const rockpile = [
    "O#..",
    "..O.",
    ".O#O",
    "O..O"]
  it('shifts rocks left', () => {
    const result = dragRocks(DIRS.L, rockpile)
    assert.deepEqual(result, [
      "O#..",
      "O...",
      "O.#O",
      "OO.."]
    )
  })
  it('shifts rocks right', () => {
    const result = dragRocks(DIRS.R, rockpile)
    assert.deepEqual(result, [
      "O#..",
      "...O",
      ".O#O",
      "..OO"]
    )
  })
  it('shifts rocks up', () => {
    const result = dragRocks(DIRS.U, rockpile)
    assert.deepEqual(result, [
      "O#OO",
      "OO.O",
      "..#.",
      "...."]
    )
  })
  it('shifts rocks down', () => {
    const result = dragRocks(DIRS.D, rockpile)
    assert.deepEqual(result, [
      ".#..",
      "..O.",
      "O.#O",
      "OO.O"]
    )
  })
})

describe('solvePart1', (t) => {
  describe('sample input', () => {
    assert.deepEqual(
      solvePart1(inputSample),
      136 // 5*10 + 2*9 + 4*8 + 3 * 7 + 3*4 + 1*3
    )
  })
  describe('full input', () => {
    assert.deepEqual(
      solvePart1(inputFull),
      113525
    )
  })
})

describe('rotatePart2', () => {
  describe('sample', () => {
    assert.deepEqual(
      rotatePart2(inputSample, 1),
      `.....#....
....#...O#
...OO##...
.OO#......
.....OOO#.
.O#...O#.#
....O#....
......OOOO
#...O###..
#..OO#....`.split('\n')
    )

    assert.deepEqual(
      rotatePart2(inputSample, 3),
    `.....#....
....#...O#
.....##...
..O#......
.....OOO#.
.O#...O#.#
....O#...O
.......OOO
#...O###.O
#.OOO#...O`.split('\n')
    )

    assert.deepEqual(
      rotatePart2(inputSample, 2),
    `.....#....
....#...O#
.....##...
..O#......
.....OOO#.
.O#...O#.#
....O#...O
.......OOO
#..OO###..
#.OOO#...O`.split('\n')
    )

    assert.deepEqual(
      solvePart2(inputFull),
      101292 // happens to be same as doing 1000 rotations...
    )
  })
})
