import fs from 'fs'
import {expect, test} from 'bun:test'

function* inputChar(input) { // this probably does not need to be a generator...
  const trimmedInput = input.trim()
  const inputLength = trimmedInput.length
  for (let i = 0; i < inputLength; i++)
    yield {i, digit: Number(trimmedInput[i])}
}

class FileBlock {
  length
  id
  constructor(length, id) {
    this.id = id
    this.length = length
  }
  isFreeSpace() {
    return false
  }
  toString() {
    return Array(this.length).fill(this.id).join('')
  }
  inspect() {
    return `File (${this.length}) #${this.id}`
  }
}
class FreeBlock {
  length
  constructor(length) {
    this.length = length
  }
  isFreeSpace() {
    return true
  }
  toString() {
    return Array(this.length).fill('.').join('')
  }
  inspect() {
    return `Free (${this.length})`
  }
}

function blocksToString(blocks) {
  return blocks.reduce((str, block) => {
    return str + block.toString()
  }, '')
}

function diskmapToArray(str) {
  const blocks = Array()
  let fileId = 0
  for (const {i, digit} of inputChar(str)) {
    if (i % 2) {
      blocks.push(new FreeBlock(digit))
    } else {
      blocks.push(new FileBlock(digit, fileId++))
    }
  }
  return blocks
}

function sumConsecutive(a, b) {
  return ((a + b) * (b - a + 1)) / 2
}

function calculateChecksum(blocks) {
  return blocks.reduce(({checksum, index}, block) => {
    if (block.isFreeSpace())
      throw new Error('ruh roh, should be no free spaces when calculating checksum')
    return {
      checksum: checksum + block.id * sumConsecutive(index, index + block.length - 1),
      index: index + block.length}
  }, {checksum: 0, index: 0}).checksum
}

function blockIsFreeSpace(block) {
  return block.isFreeSpace()
}

function doDefrag(blocks) {
  // console.log(blocks.map(b => b.toString()).join(''))
  const blocksLength = blocks.length
  const lastBlock = blocks[blocksLength - 1]
  if (lastBlock.isFreeSpace())
    return doDefrag(blocks.slice(0, blocksLength - 1))
  // lastBlock is a file...
  const nextFreeSpaceIndex = blocks.findIndex(blockIsFreeSpace)
  if (nextFreeSpaceIndex === -1)
    return blocks
  const nextFreeBlock = blocks[nextFreeSpaceIndex]
  if (nextFreeBlock.length === lastBlock.length) {
    return doDefrag(
      blocks.slice(0, nextFreeSpaceIndex)
        .concat(lastBlock, blocks.slice(nextFreeSpaceIndex + 1, blocksLength - 1)))
  } else if (nextFreeBlock.length > lastBlock.length) {
    nextFreeBlock.length -= lastBlock.length
    return doDefrag(
      blocks.slice(0, nextFreeSpaceIndex)
        .concat(
          lastBlock,
          nextFreeBlock,
          blocks.slice(nextFreeSpaceIndex + 1, blocksLength - 1)))
  } else {
    const partOfLastBlock = new FileBlock(nextFreeBlock.length, lastBlock.id)
    lastBlock.length -= nextFreeBlock.length
    return doDefrag(
      blocks.slice(0, nextFreeSpaceIndex)
      .concat(
        partOfLastBlock,
        blocks.slice(nextFreeSpaceIndex + 1, blocksLength - 1),
        lastBlock))
  }
}

function part1(input) {
  const blocks = diskmapToArray(input)
  const defragged = doDefrag(blocks)
  return calculateChecksum(defragged)
}

test('sumConsecutive', () => {
  expect(sumConsecutive(2, 4)).toEqual(2 + 3 + 4)
  expect(sumConsecutive(3, 7)).toEqual(3 + 4 + 5 + 6 + 7)
})

const sampleInput = fs.readFileSync('./sample.txt', 'utf8')
const fullInput = fs.readFileSync('./input.txt', 'utf8')

test('part 1', () => {
  expect(blocksToString([new FileBlock(1,0)])).toEqual('0')
  expect(blocksToString([new FileBlock(1,0), new FreeBlock(2), new FileBlock(3,1)])).toEqual('0..111')
  expect(blocksToString(
    diskmapToArray('12345')
  )).toEqual('0..111....22222')
  expect(blocksToString(
    doDefrag([
      new FileBlock(2,0),
      new FreeBlock(5),
      new FileBlock(3,1)
    ])
  )).toEqual('00111')
  expect(blocksToString(
    doDefrag(diskmapToArray('12345'))
  )).toEqual('022111222')
  expect(calculateChecksum(doDefrag(diskmapToArray('12345')))).toEqual(60)
  expect(part1('12345')).toEqual(60)
  expect(part1(sampleInput)).toEqual(1928)
  expect(part1(fullInput)).toEqual(6283170117911)
})
