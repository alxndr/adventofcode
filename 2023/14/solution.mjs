import {readFileSync} from 'fs'

const FILENAME_SAMPLE = 'sample.txt'
const FILENAME_FULL = 'input.txt'

const inputSample = (await readFileSync(FILENAME_SAMPLE, 'utf-8')).split(/\r?\n/)
const inputFull = (await readFileSync(FILENAME_FULL, 'utf-8')).split(/\r?\n/)
// inputSample is 2d array of chars / matrix...

const L = 'left',
  R = 'right',
  U = 'up',
  D = 'down',
  DIRS = {L,R,U,D}

const rotateR = (m) => m[0].split('').map((val, index) => m.map(row => row[index]).reverse().join(''))
const rotateL = (m) => m[0].split('').map((val, index) => m.map(row => row[row.length-1-index]).join(''));

function sortL(a, b) {
  if (a == 'O' && b == '.')
    return -1
  if (b == 'O' && a == '.')
    return 1
  return 0
}
function sortR(a, b) {
  if (a == 'O' && b == '.')
    return 1
  if (b == 'O' && a == '.')
    return -1
  return 0
}
const RE_HASH = /#/g;
function magnetize(dir) {
  const mapper = (chunk) => {
    const chunksplit = chunk.split('');
    chunksplit.sort(
      dir == L
      ? sortL
      : dir == R
      ? sortR
      : console.error.bind(this, 'ruh roh')
    ) // mutates...
    return chunksplit.join('')
  };
  return (str) => {
    return `#${str}#`
      .split(RE_HASH)
      .slice(1, -1)
      .map(mapper)
      .join('#')
  }
}

function dragRocks(dir, rockpile) {
  if (rockpile.length !== rockpile[0].length || rockpile[rockpile.length-1].length !== rockpile.length)
    throw new Error('rockpile does not look square')
  switch (dir) {
    case DIRS.U: {
      const rotated = rotateL(rockpile)
      return rotateR(rotated.map(magnetize(DIRS.L)))
    }
    case DIRS.D: {
      const rotated = rotateL(rockpile)
      return rotateR(rotated.map(magnetize(DIRS.R)))
    }
    case DIRS.L:
    case DIRS.R:
      return rockpile.map(magnetize(dir))
  }
}

const log = console.log.bind(global)

const RE_NON_ROUND_ROCKS = /[^O]+/g
function calculateLoad(input) {
  const height = input.length;
  return input.reduce((load, elem, idx) => {
    const n = elem.replace(RE_NON_ROUND_ROCKS, '').length
    return load + n*(height-idx)
  }, 0)}

function solvePart1(input) {
  const tilted = dragRocks(DIRS.U, input)
  const load = calculateLoad(tilted)
  return load
}

function rotatePart2(input, nRotations) {
  while (nRotations) {
    input = dragRocks(DIRS.U, input)
    input = dragRocks(DIRS.L, input)
    input = dragRocks(DIRS.D, input)
    input = dragRocks(DIRS.R, input)
    nRotations--;
  }
  return input;
}

function solvePart2(input) {
  // const done = rotatePart2(input, 1000000000);
  const done = rotatePart2(input, 1000);
  const load = calculateLoad(done);
  global.console.log({load})
  return load
}

export {
  DIRS,
  inputSample,
  inputFull,
  dragRocks,
  magnetize,
  calculateLoad,
  solvePart1,
  solvePart2,
  rotatePart2,
}
