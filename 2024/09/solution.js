import fs from 'fs'
import {expect, test} from 'bun:test'

const sampleInput = fs.readFileSync('./sample.txt', 'utf8')
const fullInput = fs.readFileSync('./input.txt', 'utf8')

function* inputChar(input) { // this probably does not need to be a generator...
  const trimmedInput = input.trim()
  const inputLength = trimmedInput.length
  for (let i = 0; i < inputLength; i++)
    yield {i, digit: Number(trimmedInput[i])}
}

const FREE = 'free'
const FILE = 'file'

function blockObjToString(block) {
  return Array(block.length).fill(block.type === FREE ? '.' : block.id).join('')
}

function blocksToString(blocks) {
  return blocks.reduce((str, elem) => {
    return str + blockObjToString(elem)
  }, '')
}

function diskmapToArray(str) {
  const blocks = Array()
  let fileId = -1
  for (const {i, digit} of inputChar(str)) {
    let which
    if (i % 2) {
      blocks.push({type: FREE, length: digit})
    } else {
      fileId++
      blocks.push({type: FILE, length: digit, id: fileId})
    }
  }
  return blocks
}

function sumConsecutive(a, b) {
  return ((a + b) * (b - a + 1)) / 2
}

function calculateChecksum(blocks) {
  // console.log('calculate checksum...', blocks)
  return blocks.reduce(({checksum, index}, block) => {
    // console.log({index, checksum, id: block.id, length: block.length})
    if (block.type !== FILE)
      throw new Error('ruh roh, sholud be no free spaces when calculating checksum')
    // id * (index * (sC(index + length) - sC(index - 1))
    // (@0) 0 * 0
    // (@1) 2 * 1 + 2 * 2          => 2 * 3   =>  6
    // (@3) 1 * 3 + 1 * 4 + 1 * 5  => 1 * 12  => 12
    // (@6) 2 * 6 + 2 * 7 + 2 * 8  => 2 * 21  => 42
    return {
      checksum: checksum + block.id * sumConsecutive(index, index + block.length - 1),
      index: index + block.length}
  }, {checksum: 0, index: 0}).checksum
}

function part1(input) {
  const blocks = diskmapToArray(input)
  // console.log(blocksToString(blocks))
  const defragged = doDefrag(blocks)
  // console.log({defragged})
  return calculateChecksum(defragged)
}

function blockIsFreeSpace(block) {
  return block.type === FREE
}

function doDefrag(blocks) {
  // console.log(blocks)
  const blocksLength = blocks.length
  const lastBlock = blocks[blocksLength - 1]
  if (lastBlock.type === FREE)
    return doDefrag(blocks.slice(0, blocksLength - 1))
  // lastBlock is a file...
  const nextFreeSpaceIndex = blocks.findIndex(blockIsFreeSpace)
  if (nextFreeSpaceIndex === -1)
    return blocks
  const nextFreeBlock = blocks[nextFreeSpaceIndex]
  // console.log('next free length:', nextFreeBlock.length, '@', nextFreeSpaceIndex)
  if (nextFreeBlock.length === lastBlock.length) {
    return doDefrag(
      blocks.slice(0, nextFreeSpaceIndex)
        .concat(lastBlock, blocks.slice(nextFreeSpaceIndex + 1, blocksLength - 1)))
  } else if (nextFreeBlock.length > lastBlock.length) {
    nextFreeBlock.length -= lastBlock.length
    // console.log('okay is this right??',
    //   blocks.slice(0, nextFreeSpaceIndex),
    //   lastBlock,
    //   nextFreeBlock,
    //   blocks.slice(nextFreeSpaceIndex + 1, blocksLength - 1))
    return doDefrag(
      blocks.slice(0, nextFreeSpaceIndex)
        .concat(
          lastBlock,
          nextFreeBlock,
          blocks.slice(nextFreeSpaceIndex + 1, blocksLength - 1)))
  } else {
    const partOfLastBlock = {...lastBlock, length: nextFreeBlock.length}
    lastBlock.length -= nextFreeBlock.length
    return doDefrag(
      blocks.slice(0, nextFreeSpaceIndex)
      .concat(
        partOfLastBlock,
        blocks.slice(nextFreeSpaceIndex + 1, blocksLength - 1),
        lastBlock))
  }
}

test('part 1', () => {
  expect(blocksToString([{type:FILE,length:1,id:0}])).toEqual('0')
  expect(blocksToString([{type:FILE,length:1,id:0}, {type:FREE,length:2}, {type:FILE,length:3,id:1}])).toEqual('0..111')
  expect(blocksToString(diskmapToArray('12345'))).toEqual('0..111....22222')
  expect(blocksToString(doDefrag([
    {type:FILE,length:2,id:0},
    {type:FREE,length:5},
    {type:FILE,length:3,id:1}]))).toEqual('00111')
  expect(blocksToString(doDefrag(diskmapToArray('12345')))).toEqual('022111222')
  expect(calculateChecksum(doDefrag(diskmapToArray('12345')))).toEqual(60)
  expect(part1('12345')).toEqual(60)
  expect(part1(sampleInput)).toEqual(1928)
  expect(part1(fullInput)).toEqual(6283170117911)
})
