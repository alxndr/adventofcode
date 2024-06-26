import {inputSample, inputFull} from './input.ts'
import {countEnergizedTiles, countMostEnergizedTiles, inputToMatrix} from './solution.ts'

const IS_DEBUGGING = Boolean(process.env.IS_DEBUGGING) || false

console.log('\n2023 day 16 testing...');

if (!IS_DEBUGGING) {
  const inputMatrix = inputToMatrix('foo\nbar\nbaz')
  console.assert(inputMatrix[0][0] === 'f', 'inputMatrix[0][0] doesnt look right')
  console.assert(inputMatrix[1][1] === 'a', 'inputMatrix[1][1] doesnt look right')
  console.assert(inputMatrix[2][2] === 'z', 'inputMatrix[2][2] doesnt look right')
  console.log('inputMatrix tests successful...\n')
}

console.log('part 1...\n')

if (!IS_DEBUGGING) {
  const sampleEnergizedCount = await countEnergizedTiles(inputSample)
  console.assert(sampleEnergizedCount === 46, `sample input should have 46 energized tiles, but saw: ${sampleEnergizedCount}`)
  console.log(`inputSample test: ${sampleEnergizedCount}\n`)
}

const fullEnergizedCount = await countEnergizedTiles(inputFull)
console.assert(fullEnergizedCount > 46, `full input should have lots of energized tiles, but saw: ${fullEnergizedCount}`)
console.assert(fullEnergizedCount === 7498, `full input energized count should === 7498... but saw ${fullEnergizedCount}`)
console.log(`inputFull test: ${fullEnergizedCount}\n`)

console.log('\npart2...\n')

if (!IS_DEBUGGING) {
  const mostEnergizedCountSample = countMostEnergizedTiles(inputSample)
  console.assert(mostEnergizedCountSample === 51, `sample input should have 51 energized tiles, but saw: ${mostEnergizedCountSample}`)
  console.log(`inputSample test: ${mostEnergizedCountSample}\n`)
}

const mostEnergizedCountFull = countMostEnergizedTiles(inputFull)
console.assert(mostEnergizedCountFull > 51, `sample input should have > 51 energized tiles, but saw: ${mostEnergizedCountFull}`)
console.log(`inputFull test: ${mostEnergizedCountFull}\n`)
